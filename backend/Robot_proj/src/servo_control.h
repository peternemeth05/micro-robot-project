#ifndef SERVO_CONTROL_H
#define SERVO_CONTROL_H

#include <stdint.h>

/* Number of servos (12 total - 3 per leg × 4 legs) */
#define NUM_SERVOS 12

/* Servo IDs for each leg joint */
#define SERVO_RF_SHOULDER 0   // Right Front Shoulder
#define SERVO_RF_ARM      1   // Right Front Arm
#define SERVO_RF_HAND     2   // Right Front Hand

#define SERVO_LF_SHOULDER 3   // Left Front Shoulder
#define SERVO_LF_ARM      4   // Left Front Arm
#define SERVO_LF_HAND     5   // Left Front Hand

#define SERVO_RB_SHOULDER 6   // Right Back Shoulder
#define SERVO_RB_ARM      7   // Right Back Arm
#define SERVO_RB_HAND     8   // Right Back Hand

#define SERVO_LB_SHOULDER 9   // Left Back Shoulder
#define SERVO_LB_ARM      10  // Left Back Arm
#define SERVO_LB_HAND     11  // Left Back Hand

/* Initialize servo controller */
int servo_init(void);

/* Set servo angle (0-180 degrees) */
int servo_set_angle(uint8_t servo_id, uint8_t angle);

/* Set all servos to home position (90 degrees) */
void servo_home_all(void);

/* Get current servo angle */
uint8_t servo_get_angle(uint8_t servo_id);

#endif /* SERVO_CONTROL_H */