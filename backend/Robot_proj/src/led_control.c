#include "led_control.h"
#include <zephyr/kernel.h>
#include <zephyr/device.h>
#include <zephyr/drivers/led_strip.h>
#include <zephyr/logging/log.h>

LOG_MODULE_REGISTER(led, LOG_LEVEL_INF);

#define STRIP_NODE DT_ALIAS(led_strip)
#define STRIP_NUM_PIXELS DT_PROP(DT_ALIAS(led_strip), chain_length)

static const struct device *strip = DEVICE_DT_GET(STRIP_NODE);
static struct led_rgb pixels[STRIP_NUM_PIXELS];

/* Initialize LED strip */
int led_init(void)
{
    LOG_INF("Initializing LED strip...");
    
    if (!device_is_ready(strip)) {
        LOG_ERR("LED strip device not ready");
        return -ENODEV;
    }
    
    LOG_INF("✓ LED strip ready (%d LEDs)", STRIP_NUM_PIXELS);
    
    /* Clear all LEDs on startup */
    for (int i = 0; i < STRIP_NUM_PIXELS; i++) {
        pixels[i].r = 0;
        pixels[i].g = 0;
        pixels[i].b = 0;
    }
    led_strip_update_rgb(strip, pixels, STRIP_NUM_PIXELS);
    
    return 0;
}

/* Simple blink - all LEDs white, 5 times */
void led_blink_test(void)
{
    LOG_INF("Blinking all LEDs...");
    
    for (int blink = 0; blink < 5; blink++) {
        /* Turn ON - White */
        for (int i = 0; i < STRIP_NUM_PIXELS; i++) {
            pixels[i].r = 255;
            pixels[i].g = 255;
            pixels[i].b = 255;
        }
        led_strip_update_rgb(strip, pixels, STRIP_NUM_PIXELS);
        LOG_INF("  ON");
        k_msleep(500);
        
        /* Turn OFF */
        for (int i = 0; i < STRIP_NUM_PIXELS; i++) {
            pixels[i].r = 0;
            pixels[i].g = 0;
            pixels[i].b = 0;
        }
        led_strip_update_rgb(strip, pixels, STRIP_NUM_PIXELS);
        LOG_INF("  OFF");
        k_msleep(500);
    }
    
    LOG_INF("✓ Blink complete");
}