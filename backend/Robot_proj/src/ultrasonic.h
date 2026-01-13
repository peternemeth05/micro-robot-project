#ifndef ULTRASONIC_H
#define ULTRASONIC_H

#include <stdint.h>

/* Initialize ultrasonic sensor */
int ultrasonic_init(void);

/* Get distance in centimeters */
int ultrasonic_get_distance_cm(void);

#endif /* ULTRASONIC_H */