#include <stdio.h>
#include <zephyr/kernel.h>
#include <zephyr/logging/log.h>
#include "bluetooth.h"
#include "led_control.h"
#include "ultrasonic.h"

LOG_MODULE_REGISTER(main, LOG_LEVEL_INF);

/* Distance streaming control */
static bool distance_streaming_enabled = false;
static struct k_thread distance_thread;
static K_THREAD_STACK_DEFINE(distance_stack, 1024);

/* Distance streaming thread */
static void distance_streaming_thread(void *arg1, void *arg2, void *arg3)
{
    ARG_UNUSED(arg1);
    ARG_UNUSED(arg2);
    ARG_UNUSED(arg3);
    
    LOG_INF("Distance streaming thread started");
    
    while (1) {
        if (distance_streaming_enabled && bluetooth_is_connected()) {
            int distance = ultrasonic_get_distance_cm();
            
            char response[32];
            if (distance >= 0) {
                snprintf(response, sizeof(response), "DIST:%d", distance);
            } else {
                snprintf(response, sizeof(response), "DIST:---");
            }
            
            int ret = bluetooth_send_data((const uint8_t *)response, strlen(response));
            if (ret != 0) {
                LOG_WRN("Failed to send distance data");
            }
            
            k_msleep(200);  // Send every 200ms (5 times per second)
        } else {
            k_msleep(500);  // Check less frequently when disabled
        }
    }
}

/* Bluetooth data handler */
void on_bluetooth_data_received(const uint8_t *data, uint16_t len)
{
    if (len == 0) {
        return;
    }
    
    switch (data[0]) {
        case 'T':
            bluetooth_send_data((const uint8_t *)"Blinking LEDs...", sizeof("Blinking LEDs...") - 1);
            LOG_INF("→ 'T' received - Blinking LEDs");
            led_blink_test();
            bluetooth_send_data((const uint8_t *)"Blinking Complete", sizeof("Blinking Complete") - 1);
            break;
            
        case 'D':
            LOG_INF("→ 'D' received - Get Distance (single)");
            {
                int distance = ultrasonic_get_distance_cm();
                char response[32];
                if (distance >= 0) {
                    snprintf(response, sizeof(response), "Distance: %d cm", distance);
                } else {
                    snprintf(response, sizeof(response), "No object detected");
                }
                bluetooth_send_data((const uint8_t *)response, strlen(response));
            }
            break;
            
        case 'A':
            LOG_INF("→ 'A' received - Start Auto Distance Streaming");
            distance_streaming_enabled = true;
            bluetooth_send_data((const uint8_t *)"Distance streaming ON", sizeof("Distance streaming ON") - 1);
            break;
            
        case 'Z':
            LOG_INF("→ 'Z' received - Stop Auto Distance Streaming");
            distance_streaming_enabled = false;
            break;
            
        case 'P':
            switch (data[1]) {
                case 'G':
                    bluetooth_send_data((const uint8_t *)"Executing grid walk", sizeof("Executing grid walk") - 1);
                    LOG_INF("→ 'PG' received - Executing grid walk pattern");
                    bluetooth_send_data((const uint8_t *)"Grid walk Complete", sizeof("Grid walk Complete") - 1);
                    // Call function to execute grid walk pattern
                    break;
                case 'S':
                    bluetooth_send_data((const uint8_t *)"Executing spiral walk", sizeof("Executing spiral walk") - 1);
                    LOG_INF("→ 'PS' received - Executing spiral walk pattern");
                    bluetooth_send_data((const uint8_t *)"Spiral walk Complete", sizeof("Spiral walk Complete") - 1);
                    // Call function to execute spiral walk pattern
                    break;
                case 'R':
                    bluetooth_send_data((const uint8_t *)"Executing random walk", sizeof("Executing random walk") - 1);
                    LOG_INF("→ 'PR' received - Executing random walk pattern");
                    bluetooth_send_data((const uint8_t *)"Random walk Complete", sizeof("Random walk Complete") - 1);
                    // Call function to execute random walk pattern
                    break;
                default:
                    LOG_INF("→ 'P' received with unknown pattern type: 0x%02X", data[1]);
                    break;
            }
            break;
            
        default:
            LOG_INF("Unknown command: 0x%02X", data[0]);
            break;
    }
}

int main(void)
{
    int ret;
    
    LOG_INF("========================================");
    LOG_INF("  Robot Control System");
    LOG_INF("========================================");
    
    /* Initialize LEDs */
    LOG_INF("1. Initializing LEDs...");
    ret = led_init();
    if (ret) {
        LOG_ERR("✗ LED init FAILED!");
        return ret;
    }
    LOG_INF("✓ LEDs initialized");
    
    /* Initialize Ultrasonic Sensor */
    LOG_INF("2. Initializing Ultrasonic Sensor...");
    ret = ultrasonic_init();
    if (ret) {
        LOG_ERR("✗ Ultrasonic init FAILED!");
        return ret;
    }
    LOG_INF("✓ Ultrasonic sensor initialized");
    
    /* Initialize Bluetooth */
    LOG_INF("3. Initializing Bluetooth...");
    ret = bluetooth_init();
    if (ret) {
        LOG_ERR("✗ Bluetooth init FAILED!");
        return ret;
    }
    LOG_INF("✓ Bluetooth initialized");
    
    bluetooth_register_callback(on_bluetooth_data_received);
    
    ret = bluetooth_start_advertising();
    if (ret) {
        LOG_ERR("✗ Advertising FAILED!");
        return ret;
    }
    
    /* Start distance streaming thread */
    LOG_INF("4. Starting distance streaming thread...");
    k_thread_create(&distance_thread, distance_stack,
                    K_THREAD_STACK_SIZEOF(distance_stack),
                    distance_streaming_thread,
                    NULL, NULL, NULL,
                    7, 0, K_NO_WAIT);
    k_thread_name_set(&distance_thread, "distance");
    LOG_INF("✓ Distance thread started");
    
    LOG_INF("========================================");
    LOG_INF("ROBOT READY!");
    LOG_INF("========================================");
    LOG_INF("Commands:");
    LOG_INF("  'T'  = Blink LEDs");
    LOG_INF("  'D'  = Get Distance (single)");
    LOG_INF("  'A'  = Auto distance streaming ON");
    LOG_INF("  'Z'  = Auto distance streaming OFF");
    LOG_INF("  'PG' = Grid walk pattern");
    LOG_INF("  'PS' = Spiral walk pattern");
    LOG_INF("  'PR' = Random walk pattern");
    LOG_INF("========================================");
    
    while (1) {
        k_msleep(5000);
    }
    
    return 0;
}