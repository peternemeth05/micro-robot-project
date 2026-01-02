
#include <stdio.h>
#include <zephyr/kernel.h>
#include <zephyr/drivers/gpio.h>
#include <zephyr/logging/log.h>
#include "bluetooth.h"

#define SLEEP_TIME_MS   1000
#define LED_PIN 2


LOG_MODULE_REGISTER(main, LOG_LEVEL_INF);

void on_bluetooth_data_received(const uint8_t *data, uint16_t len)
{
    LOG_INF("========================================");
    LOG_INF("Received %d bytes from phone!", len);
    LOG_INF("========================================");
    
    /* Print each byte as hex */
    for (int i = 0; i < len; i++) {
        LOG_INF("Byte %d: 0x%02X (decimal: %d)", i, data[i], data[i]);
    }
    
    /* If it's text data, try to print as characters */
    if (len > 0 && data[0] >= 32 && data[0] <= 126) {
        LOG_INF("First character: '%c'", data[0]);
    }
    
    /* Example: Control robot based on received commands */
    if (len > 0) {
        switch(data[0]) {
            case 'F':
                LOG_INF("Command: FORWARD");
                // Later: motion_set_state(MOTION_FORWARD);
                break;
                
            case 'B':
                LOG_INF("Command: BACKWARD");
                // Later: motion_set_state(MOTION_BACKWARD);
                break;
                
            case 'L':
                LOG_INF("Command: LEFT");
                // Later: motion_set_state(MOTION_LEFT);
                break;
                
            case 'R':
                LOG_INF("Command: RIGHT");
                // Later: motion_set_state(MOTION_RIGHT);
                break;
                
            case 'S':
                LOG_INF("Command: STOP");
                // Later: motion_set_state(MOTION_STOP);
                break;
                
            default:
                LOG_INF("Unknown command: 0x%02X", data[0]);
                break;
        }
    }
}


static int system_init(void) {
	int ret;
    
	/* 
     * Initialize Bluetooth subsystem
     * This turns on the BLE radio and prepares the stack
     */
    LOG_INF("Initializing Bluetooth...");
    ret = bluetooth_init();
    if (ret) {
        LOG_ERR("✗ Bluetooth init FAILED! Error: %d", ret);
        return ret;
    }
    LOG_INF("✓ Bluetooth initialized");
    
    /* 
     * Register callback for incoming Bluetooth data
     * This tells the Bluetooth module which function to call
     * when data arrives from the phone/controller
     */
    LOG_INF("Registering Bluetooth callback...");
    bluetooth_register_callback(on_bluetooth_data_received);
    LOG_INF("✓ Callback registered");
    
    /* 
     * Start Bluetooth advertising
     * Makes the robot visible to phones/tablets
     * Device will appear as "DogRobot"
     */
    LOG_INF("Starting Bluetooth advertising...");
    ret = bluetooth_start_advertising();
    if (ret) {
        LOG_ERR("✗ Advertising FAILED! Error: %d", ret);
        return ret;
    }
    LOG_INF("✓ Advertising started");
    
    return 0;
}

int main(void)
{
	int ret;
    
    LOG_INF("========================================");
    LOG_INF("ESP32 Dog Robot");
    LOG_INF("  Starting up...");
    LOG_INF("========================================");
    
    /* 
     * Initialize all robot systems
     * If this fails, we can't continue
     */
    ret = system_init();
    if (ret) {
        LOG_ERR("========================================");
        LOG_ERR("FATAL: System initialization failed!");
        LOG_ERR("Error code: %d", ret);
        LOG_ERR("Robot cannot start. Check logs above.");
        LOG_ERR("========================================");
        return ret;  // Exit program
    }
    
    LOG_INF("========================================");
    LOG_INF("ROBOT READY!");
    LOG_INF("========================================");
    LOG_INF("Instructions:");
    LOG_INF("1. Open BLE app on your phone");
    LOG_INF("2. Scan for Bluetooth devices");
    LOG_INF("3. Look for 'DogRobot'");
    LOG_INF("4. Connect to it");
    LOG_INF("5. Send commands:");
    LOG_INF("   'F' = Forward");
    LOG_INF("   'B' = Backward");
    LOG_INF("   'L' = Left");
    LOG_INF("   'R' = Right");
    LOG_INF("   'S' = Stop");
    LOG_INF("========================================");
    
    /* 
     * Main loop - runs forever
     * Monitors system status and keeps program alive
     */
    int loop_count = 0;
    
    while (1) {
        loop_count++;
        
        /* Check Bluetooth connection status */
        if (bluetooth_is_connected()) {
            LOG_INF("[%d] ✓ Connected | Waiting for commands...", loop_count);
        } else {
            LOG_INF("[%d] ○ Not connected | Waiting...", loop_count);
		}
		k_msleep(5000);
	}

	return 0;
}