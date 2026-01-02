#include "wifi_server.h"
#include <zephyr/kernel.h>
#include <zephyr/net/net_if.h>
#include <zephyr/net/wifi_mgmt.h>
#include <zephyr/net/net_event.h>
#include <zephyr/net/net_mgmt.h>
#include <zephyr/logging/log.h>
#include <string.h>

LOG_MODULE_REGISTER(wifi, LOG_LEVEL_INF);

/* WiFi state */
static bool wifi_connected = false;
static char ip_address[16] = "0.0.0.0";
static wifi_config_t wifi_cfg;

/* WiFi management event handler */
static struct net_mgmt_event_callback wifi_cb;
static struct net_mgmt_event_callback ipv4_cb;

/* Event handler for WiFi events */
static void wifi_mgmt_event_handler(struct net_mgmt_event_callback *cb,
                                    net_mgmt_event_t mgmt_event,  // ← Changed
                                    struct net_if *iface)
{
    switch (mgmt_event) {
    case NET_EVENT_WIFI_CONNECT_RESULT:
        LOG_INF("WiFi connected!");
        wifi_connected = true;
        break;
        
    case NET_EVENT_WIFI_DISCONNECT_RESULT:
        LOG_INF("WiFi disconnected");
        wifi_connected = false;
        strcpy(ip_address, "0.0.0.0");
        break;
        
    default:
        break;
    }
}

/* Event handler for IPv4 events */
static void ipv4_event_handler(struct net_mgmt_event_callback *cb,
                               net_mgmt_event_t mgmt_event,  // ← Changed
                               struct net_if *iface)
{
    if (mgmt_event == NET_EVENT_IPV4_ADDR_ADD) {
        char buf[NET_IPV4_ADDR_LEN];
        struct net_if_ipv4 *ipv4 = iface->config.ip.ipv4;
        
        if (!ipv4) {
            return;
        }
        
        for (int i = 0; i < NET_IF_MAX_IPV4_ADDR; i++) {
            if (!ipv4->unicast[i].is_used) {
                continue;
            }
            
            /* Got IP address */
            net_addr_ntop(AF_INET, &ipv4->unicast[i].address.in_addr, 
                         buf, sizeof(buf));
            strcpy(ip_address, buf);
            LOG_INF("Got IP address: %s", ip_address);
            break;
        }
    }
}

int wifi_init(wifi_config_t *config)
{
    if (config == NULL) {
        LOG_ERR("Invalid config");
        return -EINVAL;
    }
    
    LOG_INF("========================================");
    LOG_INF("Initializing WiFi...");
    LOG_INF("========================================");
    
    /* Save configuration */
    memcpy(&wifi_cfg, config, sizeof(wifi_config_t));
    
    /* Get network interface */
    struct net_if *iface = net_if_get_default();
    if (!iface) {
        LOG_ERR("No network interface found");
        return -ENODEV;
    }
    
    /* Register event callbacks */
    net_mgmt_init_event_callback(&wifi_cb, wifi_mgmt_event_handler,
                                 NET_EVENT_WIFI_CONNECT_RESULT |
                                 NET_EVENT_WIFI_DISCONNECT_RESULT);
    net_mgmt_add_event_callback(&wifi_cb);
    
    net_mgmt_init_event_callback(&ipv4_cb, ipv4_event_handler,
                                 NET_EVENT_IPV4_ADDR_ADD);
    net_mgmt_add_event_callback(&ipv4_cb);
    
    if (config->mode == WIFI_MODE_AP) {
        /* Access Point Mode */
        LOG_INF("Mode: Access Point (AP)");
        LOG_INF("SSID: %s", config->ssid);
        LOG_INF("Password: %s", config->password);
        LOG_INF("Channel: %d", config->channel);
        
        struct wifi_connect_req_params params = {
            .ssid = config->ssid,
            .ssid_length = strlen(config->ssid),
            .psk = config->password,
            .psk_length = strlen(config->password),
            .channel = config->channel,
            .security = (strlen(config->password) > 0) ? 
                       WIFI_SECURITY_TYPE_PSK : WIFI_SECURITY_TYPE_NONE,
        };
        
        /* Start AP */
        int ret = net_mgmt(NET_REQUEST_WIFI_AP_ENABLE, iface, 
                          &params, sizeof(params));
        if (ret) {
            LOG_ERR("Failed to start AP mode: %d", ret);
            return ret;
        }
        
        /* In AP mode, set static IP */
        strcpy(ip_address, "192.168.4.1");
        wifi_connected = true;
        
        LOG_INF("✓ AP mode started");
        LOG_INF("✓ IP: %s", ip_address);
        
    } else {
        /* Station Mode - Connect to existing WiFi */
        LOG_INF("Mode: Station (STA)");
        LOG_INF("Connecting to: %s", config->ssid);
        
        struct wifi_connect_req_params params = {
            .ssid = config->ssid,
            .ssid_length = strlen(config->ssid),
            .psk = config->password,
            .psk_length = strlen(config->password),
            .channel = WIFI_CHANNEL_ANY,
            .security = WIFI_SECURITY_TYPE_PSK,
            .timeout = SYS_FOREVER_MS,
        };
        
        int ret = net_mgmt(NET_REQUEST_WIFI_CONNECT, iface,
                          &params, sizeof(params));
        if (ret) {
            LOG_ERR("WiFi connection request failed: %d", ret);
            return ret;
        }
        
        LOG_INF("Waiting for connection...");
        
        /* Wait for connection (up to 15 seconds) */
        for (int i = 0; i < 15; i++) {
            if (wifi_connected) {
                LOG_INF("✓ Connected to WiFi");
                break;
            }
            k_msleep(1000);
            LOG_INF("  Connecting... %d/15", i + 1);
        }
        
        if (!wifi_connected) {
            LOG_ERR("✗ Connection timeout");
            return -ETIMEDOUT;
        }
    }
    
    LOG_INF("========================================");
    LOG_INF("WiFi initialized successfully!");
    LOG_INF("========================================");
    
    return 0;
}

bool wifi_is_ready(void)
{
    return wifi_connected;
}

const char *wifi_get_ip(void)
{
    return ip_address;
}