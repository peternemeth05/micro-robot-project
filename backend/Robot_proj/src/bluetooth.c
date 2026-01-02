#include "bluetooth.h"
#include <zephyr/kernel.h>
#include <zephyr/bluetooth/bluetooth.h>
#include <zephyr/bluetooth/conn.h>
#include <zephyr/bluetooth/gatt.h>
#include <zephyr/logging/log.h>
#include <string.h>

LOG_MODULE_REGISTER(bluetooth, LOG_LEVEL_INF); /*This allows log messages from this file to be identified and filtered.*/

static struct bt_conn *current_conn = NULL; /*This stores the active Bluetooth connection.*/
static bool is_connected = false; /*Tracks if connected to bt*/
static bt_rx_callback_t rx_callback = NULL; /*Stores the user's callback function pointer*/

/* Custom Service UUID: 12345678-1234-5678-1234-56789abcdef0 */
#define BT_UUID_CUSTOM_SERVICE_VAL \
    BT_UUID_128_ENCODE(0x12345678, 0x1234, 0x5678, 0x1234, 0x56789abcdef0)

/* Custom Characteristic UUID: 12345678-1234-5678-1234-56789abcdef1 */
#define BT_UUID_CUSTOM_CHAR_VAL \
    BT_UUID_128_ENCODE(0x12345678, 0x1234, 0x5678, 0x1234, 0x56789abcdef1)

#define BT_UUID_CUSTOM_SERVICE  BT_UUID_DECLARE_128(BT_UUID_CUSTOM_SERVICE_VAL)
#define BT_UUID_CUSTOM_CHAR     BT_UUID_DECLARE_128(BT_UUID_CUSTOM_CHAR_VAL)


/* Connection callbacks: Callback function automatically called by Zephyr when a device connects */
static void connected(struct bt_conn *conn, uint8_t err)
{
    /*If err is non-zero (connection failed)*/
    if (err) {
        LOG_ERR("Connection failed: %u", err);
        return;
    }
    
    LOG_INF("Connected!");
    current_conn = bt_conn_ref(conn); /*prevents the connection from being freed while we're using it*/
    is_connected = true;
}

/*Callback automatically called when device disconnects.*/
static void disconnected(struct bt_conn *conn, uint8_t reason)
{
    LOG_INF("Disconnected (reason %u)", reason);
    
    /* Check if we have a stored connection*/
    if (current_conn) {
        bt_conn_unref(current_conn); /*Allows Zephyr to free the connection memory.*/
        current_conn = NULL;
    }
    is_connected = false;
}

/* GATT Write Callback - Called when phone sends data */
static ssize_t write_custom_char(struct bt_conn *conn,
                                 const struct bt_gatt_attr *attr,
                                 const void *buf, uint16_t len,
                                 uint16_t offset, uint8_t flags)
{
    const uint8_t *data = buf;
    
    LOG_INF("Received %d bytes via GATT", len);
    
    /* Call user callback if registered */
    if (rx_callback && len > 0) {
        rx_callback(data, len);
    }
    
    return len;
}

/* GATT Read Callback - Called when phone reads data */
static ssize_t read_custom_char(struct bt_conn *conn,
                               const struct bt_gatt_attr *attr,
                               void *buf, uint16_t len, uint16_t offset)
{
    const char *value = "OK";
    return bt_gatt_attr_read(conn, attr, buf, len, offset, value, strlen(value));
}

/* Define GATT Service and Characteristic */
BT_GATT_SERVICE_DEFINE(custom_svc,
    BT_GATT_PRIMARY_SERVICE(BT_UUID_CUSTOM_SERVICE),
    BT_GATT_CHARACTERISTIC(BT_UUID_CUSTOM_CHAR,
                          BT_GATT_CHRC_READ | BT_GATT_CHRC_WRITE | BT_GATT_CHRC_WRITE_WITHOUT_RESP,
                          BT_GATT_PERM_READ | BT_GATT_PERM_WRITE,
                          read_custom_char, write_custom_char, NULL),
);

BT_CONN_CB_DEFINE(conn_callbacks) = {
    .connected = connected, /*When connection happens, calls the connected() function*/
    .disconnected = disconnected, /*When disconnection happens, call the disconnected() function*/
};

/* Advertisement parameters: defines how device is advertised */
static const struct bt_le_adv_param adv_param = {
    .id = BT_ID_DEFAULT,
    .sid = 0,
    .secondary_max_skip = 0,
    .options = BT_LE_ADV_OPT_CONN | BT_LE_ADV_OPT_USE_NAME,
    .interval_min = BT_GAP_ADV_FAST_INT_MIN_2,
    .interval_max = BT_GAP_ADV_FAST_INT_MAX_2,
    .peer = NULL,
};

/* Advertisement data: Array of data packets to broadcast */
static const struct bt_data ad[] = {
    BT_DATA_BYTES(BT_DATA_FLAGS, BT_LE_AD_GENERAL | BT_LE_AD_NO_BREDR),
    BT_DATA_BYTES(BT_DATA_UUID128_ALL, BT_UUID_CUSTOM_SERVICE_VAL),  // ← ADDED
}; /*Tells scanners its a BLE device*/


/*Initialises bluetooth*/
int bluetooth_init(void)
{
    int err; /*Store error codes*/
    
    LOG_INF("Initializing Bluetooth...");
    
    err = bt_enable(NULL); /*Powers on the BLE radio*/
    /* if err!=0, log and returns error code*/
    if (err) {
        LOG_ERR("Bluetooth init failed (err %d)", err);
        return err;
    }
    
    LOG_INF("Bluetooth initialized");
    LOG_INF("GATT service registered"); 

    return 0;
}


/*Start broadcasting presence to other devices*/
int bluetooth_start_advertising(void)
{
    int err;
    
    LOG_INF("Starting advertising...");
    
    err = bt_le_adv_start(&adv_param, ad, ARRAY_SIZE(ad), NULL, 0); /*Starts broadcasting BLE ad packets*/
    if (err) {
        LOG_ERR("Advertising failed (err %d)", err);
        return err;
    }
    
    LOG_INF("Advertising as '%s'", CONFIG_BT_DEVICE_NAME);
    return 0;
}


/*Returns current connection status*/
bool bluetooth_is_connected(void)
{
    return is_connected;
}


/**/
void bluetooth_register_callback(bt_rx_callback_t callback)
{
    rx_callback = callback;
    LOG_INF("RX callback registered");
}