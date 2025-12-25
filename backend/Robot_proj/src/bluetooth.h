/*If BLUETOOTH_h not defined, the next lines defines it in the code until endif
if defined, then skips to endif*/
#ifndef BLUETOOTH_H 
#define BLUETOOTH_H

#include <stdint.h> /*Provides fixed-width integer types like uint8_t, uint16_t*/
#include <stdbool.h> /*Provides the bool type (true/false)*/

/* Initialize Bluetooth: Function declaration that will initialize the Bluetooth stack. Returns int (0 for success, negative for error) */ 
int bluetooth_init(void);

/* Start advertising: Function to start BLE advertising so other devices can discover this device. Returns status code. */
int bluetooth_start_advertising(void);

/* Check if connected: Returns true if a device is currently connected via Bluetooth, false otherwise. */
bool bluetooth_is_connected(void);

/* Callback for received data: This allows users to register their own function to handle incoming Bluetooth data*/
typedef void (*bt_rx_callback_t)(const uint8_t *data, uint16_t len);

/* Register callback for incoming data */
void bluetooth_register_callback(bt_rx_callback_t callback);

#endif /* BLUETOOTH_H */