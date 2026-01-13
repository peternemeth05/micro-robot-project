#include "servo_control.h"
#include <zephyr/kernel.h>
#include <zephyr/device.h>
#include <zephyr/drivers/i2c.h>
#include <zephyr/logging/log.h>

LOG_MODULE_REGISTER(servo, LOG_LEVEL_INF);

/* PCA9685 I2C Configuration */
#define PCA9685_I2C_ADDR    0x40
#define PCA9685_I2C_NODE    DT_NODELABEL(i2c_bitbang)

/* PCA9685 Register Addresses */
#define PCA9685_MODE1       0x00
#define PCA9685_MODE2       0x01
#define PCA9685_PRESCALE    0xFE
#define PCA9685_LED0_ON_L   0x06

/* PWM Configuration */
#define PCA9685_PWM_FREQ    50    // 50Hz for servos
#define PCA9685_RESOLUTION  4096  // 12-bit resolution

/* Servo pulse width range (microseconds) */
#define SERVO_MIN_PULSE_US  500
#define SERVO_MAX_PULSE_US  2500

#define SERVO_MAX_ANGLE     180
#define SERVO_HOME_ANGLE    90

/* Servo state tracking */
typedef struct {
    uint8_t current_angle;
    bool initialized;
} servo_state_t;

static servo_state_t servos[NUM_SERVOS];
static const struct device *i2c_dev;
static struct k_mutex servo_mutex;

/* Write to PCA9685 register */
static int pca9685_write_reg(uint8_t reg, uint8_t value)
{
    uint8_t data[2] = {reg, value};
    return i2c_write(i2c_dev, data, 2, PCA9685_I2C_ADDR);
}

/* Set PWM for a specific channel */
static int pca9685_set_pwm(uint8_t channel, uint16_t on, uint16_t off)
{
    if (channel > 15) {
        return -EINVAL;
    }
    
    uint8_t reg_base = PCA9685_LED0_ON_L + (4 * channel);
    uint8_t data[5];
    data[0] = reg_base;
    data[1] = on & 0xFF;
    data[2] = (on >> 8) & 0x0F;
    data[3] = off & 0xFF;
    data[4] = (off >> 8) & 0x0F;
    
    return i2c_write(i2c_dev, data, 5, PCA9685_I2C_ADDR);
}

/* Scan I2C bus */
static void i2c_scan(void)
{
    LOG_INF("========================================");
    LOG_INF("Detailed I2C Bus Scan");
    LOG_INF("========================================");
    
    bool found = false;
    
    for (uint8_t addr = 0x03; addr < 0x78; addr++) {
        uint8_t dummy;
        
        // Try multiple times
        int ret = -1;
        for (int attempt = 0; attempt < 3; attempt++) {
            ret = i2c_read(i2c_dev, &dummy, 1, addr);
            if (ret == 0) {
                break;
            }
            k_msleep(10);
        }
        
        if (ret == 0) {
            LOG_INF("✓ FOUND: Device at address 0x%02X", addr);
            found = true;
        }
        
        // Show progress every 16 addresses
        if (addr % 16 == 15) {
            LOG_INF("  Scanned up to 0x%02X...", addr);
        }
    }
    
    if (!found) {
        LOG_ERR("========================================");
        LOG_ERR("NO I2C DEVICES FOUND!");
        LOG_ERR("========================================");
    }
    
    LOG_INF("========================================");
}

/* Initialize PCA9685 - Freenove sequence */
/* Initialize PCA9685 - Exact Freenove sequence */
static int pca9685_init(void)
{
    int ret;
    
    LOG_INF("Initializing PCA9685 (Freenove sequence)...");
    
    // Freenove does: Wire.setClock(100000);
    ret = i2c_configure(i2c_dev, I2C_SPEED_SET(I2C_SPEED_STANDARD) | I2C_MODE_CONTROLLER);
    if (ret < 0) {
        LOG_ERR("Failed to configure I2C: %d", ret);
        return ret;
    }
    
    // Freenove does: writeReg(MODE1, 0x00);
    ret = pca9685_write_reg(PCA9685_MODE1, 0x00);
    if (ret < 0) {
        LOG_ERR("Failed to reset PCA9685: %d", ret);
        return ret;
    }
    
    LOG_INF("✓ PCA9685 reset successful");
    
    // Wait a bit after reset
    k_msleep(10);
    
    // Freenove does: setFreq(50);
    // Calculate prescale for 50Hz (same formula as Freenove)
    uint8_t prescaleVal = (uint8_t)((25000000.0f / 4096.0f / 50.0f) - 1);
    
    // Read current MODE1
    uint8_t reg_addr = PCA9685_MODE1;
    uint8_t oldMode;
    ret = i2c_write_read(i2c_dev, PCA9685_I2C_ADDR, &reg_addr, 1, &oldMode, 1);
    if (ret < 0) {
        LOG_ERR("Failed to read MODE1: %d", ret);
        return ret;
    }
    
    // Enter sleep mode
    uint8_t newMode = (oldMode & 0x7F) | 0x10;
    ret = pca9685_write_reg(PCA9685_MODE1, newMode);
    if (ret < 0) {
        LOG_ERR("Failed to enter sleep: %d", ret);
        return ret;
    }
    
    // Set prescale
    ret = pca9685_write_reg(PCA9685_PRESCALE, prescaleVal);
    if (ret < 0) {
        LOG_ERR("Failed to set prescale: %d", ret);
        return ret;
    }
    
    LOG_INF("PCA9685 prescale=%d (50Hz)", prescaleVal);
    
    // Restore old mode
    ret = pca9685_write_reg(PCA9685_MODE1, oldMode);
    if (ret < 0) {
        return ret;
    }
    
    // Wait 500 microseconds (Freenove does this)
    k_usleep(500);
    
    // Enable restart
    ret = pca9685_write_reg(PCA9685_MODE1, oldMode | 0x80);
    if (ret < 0) {
        return ret;
    }
    
    LOG_INF("✓ PCA9685 initialized (Freenove method)");
    return 0;
}

/* Convert angle to pulse width */
static uint32_t angle_to_pulse(uint8_t angle)
{
    if (angle > SERVO_MAX_ANGLE) {
        angle = SERVO_MAX_ANGLE;
    }
    
    return SERVO_MIN_PULSE_US + 
           ((angle * (SERVO_MAX_PULSE_US - SERVO_MIN_PULSE_US)) / SERVO_MAX_ANGLE);
}

/* Convert pulse width to ticks */
static uint16_t pulse_to_ticks(uint32_t pulse_us)
{
    return (uint16_t)((pulse_us * PCA9685_RESOLUTION) / 20000);
}

/* Initialize servo system */
int servo_init(void)
{
    int ret;
    
    LOG_INF("========================================");
    LOG_INF("Initializing Servo Control...");
    LOG_INF("========================================");
    
    /* Get I2C device */
    i2c_dev = DEVICE_DT_GET(PCA9685_I2C_NODE);
    if (!device_is_ready(i2c_dev)) {
        LOG_ERR("I2C device not ready!");
        return -ENODEV;
    }
    LOG_INF("✓ I2C device ready (GPIO 13/14)");
    
    /* CRITICAL: Wait longer for PCA9685 to power up */
    LOG_INF("Waiting for PCA9685 power-up (5 seconds)...");
    k_msleep(5000);  // Increased from 1 second to 5 seconds
    
    /* Initialize mutex */
    k_mutex_init(&servo_mutex);
    
    /* Try to wake up PCA9685 with multiple attempts */
    LOG_INF("Attempting PCA9685 initialization...");
    
    for (int attempt = 1; attempt <= 5; attempt++) {
        LOG_INF("  Attempt %d/5...", attempt);
        
        /* Scan I2C bus first */
        i2c_scan();
        
        /* Try to initialize */
        ret = pca9685_init();
        
        if (ret == 0) {
            LOG_INF("✓ PCA9685 initialized on attempt %d", attempt);
            break;
        }
        
        LOG_WRN("  Failed, retrying in 2 seconds...");
        k_msleep(2000);
    }
    
    if (ret < 0) {
        LOG_ERR("========================================");
        LOG_ERR("PCA9685 initialization failed after 5 attempts!");
        LOG_ERR("========================================");
        LOG_ERR("Troubleshooting:");
        LOG_ERR("1. Check power switch is ON");
        LOG_ERR("2. Check batteries are installed and charged");
        LOG_ERR("3. Check GPIO 13/14 connections");
        LOG_ERR("4. Verify PCA9685 has power (VCC + V+)");
        LOG_ERR("========================================");
        return ret;
    }
    
    /* Initialize servo states */
    for (int i = 0; i < NUM_SERVOS; i++) {
        servos[i].current_angle = SERVO_HOME_ANGLE;
        servos[i].initialized = false;
    }
    
    /* Home all servos */
    LOG_INF("Homing servos to 90°...");
    servo_home_all();
    
    for (int i = 0; i < NUM_SERVOS; i++) {
        servos[i].initialized = true;
    }
    
    LOG_INF("========================================");
    LOG_INF("✓ %d servos initialized", NUM_SERVOS);
    LOG_INF("========================================");
    
    return 0;
}

/* Set servo angle */
int servo_set_angle(uint8_t servo_id, uint8_t angle)
{
    if (servo_id >= NUM_SERVOS) {
        LOG_ERR("Invalid servo ID: %d", servo_id);
        return -EINVAL;
    }
    
    if (angle > SERVO_MAX_ANGLE) {
        angle = SERVO_MAX_ANGLE;
    }
    
    k_mutex_lock(&servo_mutex, K_FOREVER);
    
    uint32_t pulse_us = angle_to_pulse(angle);
    uint16_t ticks = pulse_to_ticks(pulse_us);
    
    int ret = pca9685_set_pwm(servo_id, 0, ticks);
    
    if (ret == 0) {
        servos[servo_id].current_angle = angle;
        LOG_DBG("Servo %d → %d° (%d us)", servo_id, angle, pulse_us);
    } else {
        LOG_ERR("Failed to set servo %d: %d", servo_id, ret);
    }
    
    k_mutex_unlock(&servo_mutex);
    
    return ret;
}

/* Home all servos */
void servo_home_all(void)
{
    LOG_INF("Homing all servos...");
    
    for (int i = 0; i < NUM_SERVOS; i++) {
        servo_set_angle(i, SERVO_HOME_ANGLE);
        k_msleep(10);
    }
    
    LOG_INF("✓ All servos homed");
}

/* Get servo angle */
uint8_t servo_get_angle(uint8_t servo_id)
{
    if (servo_id >= NUM_SERVOS) {
        return 0;
    }
    return servos[servo_id].current_angle;
}

/* Disable all servos */
void servo_disable_all(void)
{
    LOG_INF("Disabling all servos...");
    
    k_mutex_lock(&servo_mutex, K_FOREVER);
    
    for (int i = 0; i < NUM_SERVOS; i++) {
        pca9685_set_pwm(i, 0, 0);
    }
    
    k_mutex_unlock(&servo_mutex);
    
    LOG_INF("✓ All servos disabled");
}