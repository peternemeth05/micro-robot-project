#include <stdio.h>
#include <zephyr/kernel.h>
#include <zephyr/drivers/gpio.h>
#include <zephyr/logging/log.h>
#include "bluetooth.h"
#include "servo_control.h"
#include "motion_control.h"

LOG_MODULE_REGISTER(main, LOG_LEVEL_INF);

/* Bluetooth data handler - checks index and calls appropriate function */
void on_bluetooth_data_received(const uint8_t *data, uint16_t len)
{
    LOG_INF("========================================");
    LOG_INF("Received %d bytes via Bluetooth", len);
    LOG_INF("========================================");
    
    if (len == 0) {
        LOG_WRN("Empty data received");
        return;
    }
    
    /* Check first byte (index 0) to determine command type */
    uint8_t command = data[0];
    
    LOG_INF("Command byte [0]: 0x%02X ('%c')", command, 
            (command >= 0x20 && command <= 0x7E) ? command : '?');
    
    /* Check for motion commands with parameters (3-byte format) */
    switch (command) {
        case 'F': // FORWARD
            if (len >= 3) {
                uint8_t angle = data[1];
                uint8_t speed = data[2];
                LOG_INF("→ 'F' with params: Calling motion_move_forward(angle=%d, speed=%d)", angle, speed);
                motion_move_forward(angle, speed);
            } else {
                LOG_INF("→ 'F' simple: Calling motion_move_forward(0, SPEED_MEDIUM)");
                motion_move_forward(0, SPEED_MEDIUM);
            }
            break;
            
        case 'B': // BACKWARD
            if (len >= 3) {
                uint8_t angle = data[1];
                uint8_t speed = data[2];
                LOG_INF("→ 'B' with params: Calling motion_move_backward(angle=%d, speed=%d)", angle, speed);
                motion_move_backward(angle, speed);
            } else {
                LOG_INF("→ 'B' simple: Calling motion_move_backward(0, SPEED_MEDIUM)");
                motion_move_backward(0, SPEED_MEDIUM);
            }
            break;
            
        case 'L': // WALK LEFT
            if (len >= 3) {
                uint8_t angle = data[1];
                uint8_t speed = data[2];
                LOG_INF("→ 'L' with params: Calling motion_walk_left(angle=%d, speed=%d)", angle, speed);
                motion_walk_left(angle, speed);
            } else {
                LOG_INF("→ 'L' simple: Calling motion_walk_left(45, SPEED_MEDIUM)");
                motion_walk_left(45, SPEED_MEDIUM);
            }
            break;
            
        case 'R': // WALK RIGHT
            if (len >= 3) {
                uint8_t angle = data[1];
                uint8_t speed = data[2];
                LOG_INF("→ 'R' with params: Calling motion_walk_right(angle=%d, speed=%d)", angle, speed);
                motion_walk_right(angle, speed);
            } else {
                LOG_INF("→ 'R' simple: Calling motion_walk_right(45, SPEED_MEDIUM)");
                motion_walk_right(45, SPEED_MEDIUM);
            }
            break;
            
        case 'S': // STOP
            LOG_INF("→ 'S' - Calling motion_stop()");
            motion_stop();
            break;
            
        case 'W': // WAVE
            LOG_INF("→ 'W' - Calling motion_wave()");
            motion_wave();
            break;
            
        case 'T': // TEST SERVOS
            LOG_INF("→ 'T' - Calling motion_test_servos()");
            motion_test_servos();
            break;
            
        case 'H': // HOME ALL
            LOG_INF("→ 'H' - Calling servo_home_all()");
            motion_stop();
            servo_home_all();
            break;
            
        default:
            LOG_WRN("Unknown command: 0x%02X", command);
            if (command >= 0x20 && command <= 0x7E) {
                LOG_WRN("  (ASCII: '%c')", command);
            }
            break;
    }
}

/* System initialization */
static int system_init(void) {
    int ret;
    
    LOG_INF("========================================");
    LOG_INF("  Robot System Initialization");
    LOG_INF("========================================");
    
    /* Initialize Servo Control */
    LOG_INF("1. Initializing Servos...");
    ret = servo_init();
    if (ret) {
        LOG_ERR("✗ Servo init FAILED! Error: %d", ret);
        return ret;
    }
    LOG_INF("✓ Servos initialized");
    
    /* Initialize Motion Control */
    LOG_INF("2. Initializing Motion Control...");
    ret = motion_init();
    if (ret) {
        LOG_ERR("✗ Motion init FAILED! Error: %d", ret);
        return ret;
    }
    LOG_INF("✓ Motion control initialized");
    
    /* Initialize Bluetooth */
    LOG_INF("3. Initializing Bluetooth...");
    ret = bluetooth_init();
    if (ret) {
        LOG_ERR("✗ Bluetooth init FAILED! Error: %d", ret);
        return ret;
    }
    LOG_INF("✓ Bluetooth initialized");
    
    /* Register Bluetooth callback */
    LOG_INF("4. Registering Bluetooth callback...");
    bluetooth_register_callback(on_bluetooth_data_received);
    LOG_INF("✓ Callback registered");
    
    /* Start Bluetooth advertising */
    LOG_INF("5. Starting Bluetooth advertising...");
    ret = bluetooth_start_advertising();
    if (ret) {
        LOG_ERR("✗ Advertising FAILED! Error: %d", ret);
        return ret;
    }
    LOG_INF("✓ Advertising started");
    
    LOG_INF("========================================");
    LOG_INF("All systems initialized!");
    LOG_INF("========================================");
    
    return 0;
}

int main(void)
{
    int ret;
    
    LOG_INF("========================================");
    LOG_INF("  Freenove ESP32 Dog Robot");
    LOG_INF("  Index-Based Motion Control");
    LOG_INF("========================================");
    
    /* Initialize all systems */
    ret = system_init();
    if (ret) {
        LOG_ERR("========================================");
        LOG_ERR("FATAL: System initialization failed!");
        LOG_ERR("Error code: %d", ret);
        LOG_ERR("========================================");
        return ret;
    }
    
    LOG_INF("========================================");
    LOG_INF("ROBOT READY!");
    LOG_INF("========================================");
    LOG_INF("");
    LOG_INF("Command Format: [letter, angle, speed]");
    LOG_INF("");
    LOG_INF("MOTION COMMANDS:");
    LOG_INF("  Simple (1 byte):");
    LOG_INF("    'F' = Forward (medium speed)");
    LOG_INF("    'B' = Backward (medium speed)");
    LOG_INF("    'L' = Walk Left (45° angle, medium speed)");
    LOG_INF("    'R' = Walk Right (45° angle, medium speed)");
    LOG_INF("    'S' = Stop");
    LOG_INF("");
    LOG_INF("  With Parameters (3 bytes):");
    LOG_INF("    ['F', angle, speed] = Forward with diagonal angle");
    LOG_INF("    ['B', angle, speed] = Backward with diagonal angle");
    LOG_INF("    ['L', angle, speed] = Walk Left (angle controls step size)");
    LOG_INF("    ['R', angle, speed] = Walk Right (angle controls step size)");
    LOG_INF("");
    LOG_INF("SPECIAL COMMANDS (1 byte):");
    LOG_INF("  'W' = Wave");
    LOG_INF("  'T' = Test All Servos");
    LOG_INF("  'H' = Home Position");
    LOG_INF("");
    LOG_INF("Parameters:");
    LOG_INF("  angle: 0-180° (0=minimal, 90=full stride, 180=max)");
    LOG_INF("  speed: 1=Slow, 2=Medium, 3=Fast");
    LOG_INF("");
    LOG_INF("Examples:");
    LOG_INF("  ['F']          → Forward, medium speed");
    LOG_INF("  ['F', 0, 3]    → Forward, fast speed");
    LOG_INF("  ['L', 30, 1]   → Walk left (small steps), slow");
    LOG_INF("  ['R', 90, 2]   → Walk right (full strides), medium");
    LOG_INF("  ['W']          → Wave gesture");
    LOG_INF("========================================");
    
    /* Main loop */
    int loop_count = 0;
    
    while (1) {
        loop_count++;
        
        if (bluetooth_is_connected()) {
            LOG_INF("[%d] ✓ Connected | Waiting for commands", loop_count);
        } else {
            LOG_INF("[%d] ○ Waiting for Bluetooth connection...", loop_count);
        }
        
        k_msleep(5000);
    }
    
    return 0;
}