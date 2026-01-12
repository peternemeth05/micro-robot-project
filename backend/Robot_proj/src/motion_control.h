#ifndef MOTION_CONTROL_H
#define MOTION_CONTROL_H

#include <stdint.h>

/* Motion command structure */
typedef struct {
    uint8_t direction;  // Direction code
    uint8_t angle;      // Turning angle (0-180)
    uint8_t speed;      // Speed level (1-3)
} motion_cmd_t;

/* Direction codes */
#define DIR_FORWARD     0x01
#define DIR_BACKWARD    0x02
#define DIR_WALK_LEFT   0x03
#define DIR_WALK_RIGHT  0x04
#define DIR_STOP        0x00

/* Speed levels */
#define SPEED_SLOW      1
#define SPEED_MEDIUM    2
#define SPEED_FAST      3

/* Initialize motion control system */
int motion_init(void);

/* Stop all motion */
void motion_stop(void);

/* Execute specific motion with parameters */
int motion_move_forward(uint8_t angle, uint8_t speed);
int motion_move_backward(uint8_t angle, uint8_t speed);
int motion_walk_left(uint8_t angle, uint8_t speed);
int motion_walk_right(uint8_t angle, uint8_t speed);

/* Special actions */
int motion_wave(void);
int motion_test_servos(void);

#endif /* MOTION_CONTROL_H */