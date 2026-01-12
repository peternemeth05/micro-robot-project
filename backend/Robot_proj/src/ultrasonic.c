#include "ultrasonic.h"
#include <zephyr/kernel.h>
#include <zephyr/logging/log.h>
#include <soc.h>

LOG_MODULE_REGISTER(ultrasonic, LOG_LEVEL_INF);

/* HC-SR04 Pins */
#define TRIG_PIN 32
#define ECHO_PIN 12

/* ESP32 GPIO Register base addresses 
 * GPIO 0-31 use regular registers
 * GPIO 32-39 use high registers (GPIO1)
 */
#define GPIO_OUT_REG       (*(volatile uint32_t *)0x3FF44004)
#define GPIO_OUT_W1TS_REG  (*(volatile uint32_t *)0x3FF44008)
#define GPIO_OUT_W1TC_REG  (*(volatile uint32_t *)0x3FF4400C)
#define GPIO_IN_REG        (*(volatile uint32_t *)0x3FF4403C)
#define GPIO_ENABLE_REG    (*(volatile uint32_t *)0x3FF44020)

#define GPIO1_OUT_REG      (*(volatile uint32_t *)0x3FF44010)
#define GPIO1_OUT_W1TS_REG (*(volatile uint32_t *)0x3FF44014)
#define GPIO1_OUT_W1TC_REG (*(volatile uint32_t *)0x3FF44018)
#define GPIO1_IN_REG       (*(volatile uint32_t *)0x3FF44040)
#define GPIO1_ENABLE_REG   (*(volatile uint32_t *)0x3FF4402C)

/* ROM function for microsecond delay */
extern void ets_delay_us(uint32_t us);

/* Get microsecond timestamp */
static inline uint32_t micros(void)
{
    return k_cyc_to_us_floor32(k_cycle_get_32());
}

/* Initialize ultrasonic sensor */
int ultrasonic_init(void)
{
    LOG_INF("Initializing HC-SR04 with direct register access...");
    
    /* Set TRIG (GPIO32) as output - use GPIO1 registers */
    GPIO1_ENABLE_REG |= (1UL << (TRIG_PIN - 32));
    GPIO1_OUT_W1TC_REG = (1UL << (TRIG_PIN - 32));  // Set low
    
    /* ECHO (GPIO12) is input by default - use GPIO registers */
    GPIO_ENABLE_REG &= ~(1UL << ECHO_PIN);
    
    LOG_INF("✓ HC-SR04 initialized (TRIG=GPIO%d, ECHO=GPIO%d)", TRIG_PIN, ECHO_PIN);
    
    k_msleep(500);
    
    LOG_INF("Testing sensor...");
    int test_distance = ultrasonic_get_distance_cm();
    if (test_distance >= 0) {
        LOG_INF("✓ Sensor OK - %d cm", test_distance);
    } else {
        LOG_WRN("⚠ No object detected (place object 10-30cm in front)");
    }
    
    return 0;
}

/* Get distance in centimeters */
int ultrasonic_get_distance_cm(void)
{
    uint32_t pulse_start, pulse_end;
    uint32_t pulse_width_us;
    int distance_cm;
    uint32_t timeout;
    
    /* 1. Send trigger pulse - GPIO32 uses GPIO1 registers */
    GPIO1_OUT_W1TC_REG = (1UL << (TRIG_PIN - 32));  // LOW
    ets_delay_us(2);
    
    GPIO1_OUT_W1TS_REG = (1UL << (TRIG_PIN - 32));  // HIGH
    ets_delay_us(10);
    
    GPIO1_OUT_W1TC_REG = (1UL << (TRIG_PIN - 32));  // LOW
    
    /* 2. Wait for ECHO (GPIO12) to go HIGH - use GPIO registers */
    timeout = micros();
    while ((GPIO_IN_REG & (1UL << ECHO_PIN)) == 0) {
        if ((micros() - timeout) > 30000) {
            LOG_DBG("Timeout: ECHO never went HIGH");
            return -1;
        }
    }
    pulse_start = micros();
    
    /* 3. Wait for ECHO to go LOW */
    while ((GPIO_IN_REG & (1UL << ECHO_PIN)) != 0) {
        if ((micros() - pulse_start) > 30000) {
            LOG_DBG("Timeout: ECHO stuck HIGH");
            return -1;
        }
    }
    pulse_end = micros();
    
    /* 4. Calculate pulse width */
    pulse_width_us = pulse_end - pulse_start;
    
    /* 5. Calculate distance: distance = pulse_width / 58 */
    distance_cm = pulse_width_us / 58;
    
    /* 6. Validate range (2-400cm) */
    if (distance_cm < 2 || distance_cm > 400) {
        LOG_DBG("Out of range: %d cm", distance_cm);
        return -1;
    }
    
    LOG_INF("Distance: %d cm (pulse: %u us)", distance_cm, pulse_width_us);
    
    return distance_cm;
}