
#include <stdio.h>
#include <zephyr/kernel.h>
#include <zephyr/drivers/gpio.h>

#define SLEEP_TIME_MS   1000
#define LED_PIN 2
/*hello*/

int main(void)
{
	int ret;
	bool led_state = false;
	const struct device *gpio_dev;

	/* Get the GPIO device */
	gpio_dev = DEVICE_DT_GET(DT_NODELABEL(gpio0));
	
	if (!device_is_ready(gpio_dev)) {
		printf("Error: GPIO device not ready\n");
		return 0;
	}

	/* Configure GPIO2 as output */
	ret = gpio_pin_configure(gpio_dev, LED_PIN, GPIO_OUTPUT_INACTIVE);
	if (ret < 0) {
		printf("Error %d: Failed to configure LED pin\n", ret);
		return 0;
	}

	printf("ESP32 WROVER LED Blink - GPIO2\n");

	while (1) {
		led_state = !led_state;
		
		ret = gpio_pin_set(gpio_dev, LED_PIN, led_state ? 1 : 0);
		if (ret < 0) {
			printf("Error %d: Failed to set LED pin\n", ret);
			return 0;
		}

		printf("LED state: %s\n", led_state ? "ON" : "OFF");
		k_msleep(SLEEP_TIME_MS);
	}

	return 0;
}