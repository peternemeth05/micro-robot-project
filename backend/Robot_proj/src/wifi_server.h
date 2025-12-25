#ifndef WIFI_SERVER_H
#define WIFI_SERVER_H

#include <stdint.h>
#include <stdbool.h>
#include <zephyr/net/wifi_mgmt.h>

/* Use Zephyr's built-in WiFi mode enum */
/* wifi_iface_mode already defined in wifi_mgmt.h:
 * WIFI_MODE_INFRA = 1  (Station mode)
 * WIFI_MODE_IBSS = 2   (Ad-hoc)
 * WIFI_MODE_AP = 3     (Access Point)
 */

/* WiFi configuration */
typedef struct {
    char ssid[32];
    char password[64];
    enum wifi_iface_mode mode;  // Use Zephyr's enum
    uint8_t channel;             // For AP mode (1-11)
} wifi_config_t;

/* Initialize WiFi */
int wifi_init(wifi_config_t *config);

/* Check if WiFi is connected/ready */
bool wifi_is_ready(void);

/* Get IP address as string */
const char *wifi_get_ip(void);

#endif /* WIFI_SERVER_H */