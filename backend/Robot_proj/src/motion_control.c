#include "motion_control.h"
#include "servo_control.h"
#include <zephyr/kernel.h>
#include <zephyr/logging/log.h>

LOG_MODULE_REGISTER(motion, LOG_LEVEL_INF);

/* Speed timing configurations (milliseconds per step) */
#define SPEED_SLOW_DELAY      150
#define SPEED_MEDIUM_DELAY    100
#define SPEED_FAST_DELAY      50

/* Gait angles for walking */
#define SHOULDER_FORWARD      60
#define SHOULDER_BACKWARD     120
#define SHOULDER_NEUTRAL      90

#define ARM_LIFTED            45
#define ARM_DOWN              90

#define HAND_UP               60
#define HAND_DOWN             90

/* Current motion state */
static motion_cmd_t current_motion = {0};
static bool motion_active = false;
static struct k_thread motion_thread;
static K_THREAD_STACK_DEFINE(motion_stack, 2048);

/* Get delay based on speed level */
static uint32_t get_speed_delay(uint8_t speed)
{
    switch (speed) {
        case SPEED_SLOW:
            return SPEED_SLOW_DELAY;
        case SPEED_MEDIUM:
            return SPEED_MEDIUM_DELAY;
        case SPEED_FAST:
            return SPEED_FAST_DELAY;
        default:
            return SPEED_MEDIUM_DELAY;
    }
}

/* Walking gait - alternating tripod with diagonal angle support */
static void execute_walk_step(bool forward, uint8_t angle, uint8_t speed)
{
    uint32_t delay = get_speed_delay(speed);
    
    // Calculate diagonal movement based on angle (0° = straight, 90° = full sideways)
    // angle: 0-180 where 0=straight ahead, 90=perpendicular, 180=opposite direction
    
    uint8_t shoulder_angle = forward ? SHOULDER_FORWARD : SHOULDER_BACKWARD;
    uint8_t shoulder_angle_opp = forward ? SHOULDER_BACKWARD : SHOULDER_FORWARD;
    
    /* Phase 1: Lift right front, left back, move left front and right back */
    // Lift legs
    servo_set_angle(SERVO_RF_ARM, ARM_LIFTED);
    servo_set_angle(SERVO_LB_ARM, ARM_LIFTED);
    k_msleep(delay);
    
    // Move shoulders
    servo_set_angle(SERVO_RF_SHOULDER, shoulder_angle);
    servo_set_angle(SERVO_LF_SHOULDER, shoulder_angle_opp + 30);
    servo_set_angle(SERVO_RB_SHOULDER, shoulder_angle_opp + 30);
    servo_set_angle(SERVO_LB_SHOULDER, shoulder_angle);
    k_msleep(delay);
    
    // Lower legs
    servo_set_angle(SERVO_RF_ARM, ARM_DOWN);
    servo_set_angle(SERVO_LB_ARM, ARM_DOWN);
    k_msleep(delay);
    
    /* Phase 2: Lift left front, right back, move right front and left back */
    // Lift legs
    servo_set_angle(SERVO_LF_ARM, ARM_LIFTED);
    servo_set_angle(SERVO_RB_ARM, ARM_LIFTED);
    k_msleep(delay);
    
    // Move shoulders
    servo_set_angle(SERVO_LF_SHOULDER, shoulder_angle);
    servo_set_angle(SERVO_RF_SHOULDER, shoulder_angle_opp + 30);
    servo_set_angle(SERVO_LB_SHOULDER, shoulder_angle_opp + 30);
    servo_set_angle(SERVO_RB_SHOULDER, shoulder_angle);
    k_msleep(delay);
    
    // Lower legs
    servo_set_angle(SERVO_LF_ARM, ARM_DOWN);
    servo_set_angle(SERVO_RB_ARM, ARM_DOWN);
    k_msleep(delay);
}

/* Sideways walking gait - crab walk left or right */
static void execute_sidestep(bool left, uint8_t angle, uint8_t speed)
{
    uint32_t delay = get_speed_delay(speed);
    
    // Calculate step size based on angle (0-180)
    // angle determines how far to the side we move
    // 0° = minimal side step, 90° = full side step, 180° = extreme side step
    uint8_t step_amount = (angle * 45) / 90; // Map 0-90° to 0-45° servo movement
    if (step_amount > 45) step_amount = 45;
    
    if (left) {
        /* Walk left - right legs push, left legs pull */
        
        // Phase 1: Lift and move right side out
        servo_set_angle(SERVO_RF_ARM, ARM_LIFTED);
        servo_set_angle(SERVO_RB_ARM, ARM_LIFTED);
        k_msleep(delay);
        
        // Push right side to the right
        servo_set_angle(SERVO_RF_SHOULDER, SHOULDER_NEUTRAL + step_amount);
        servo_set_angle(SERVO_RB_SHOULDER, SHOULDER_NEUTRAL + step_amount);
        k_msleep(delay);
        
        // Plant right side
        servo_set_angle(SERVO_RF_ARM, ARM_DOWN);
        servo_set_angle(SERVO_RB_ARM, ARM_DOWN);
        k_msleep(delay);
        
        // Phase 2: Lift and move left side
        servo_set_angle(SERVO_LF_ARM, ARM_LIFTED);
        servo_set_angle(SERVO_LB_ARM, ARM_LIFTED);
        k_msleep(delay);
        
        // Pull left side inward (body moves left)
        servo_set_angle(SERVO_LF_SHOULDER, SHOULDER_NEUTRAL + step_amount);
        servo_set_angle(SERVO_LB_SHOULDER, SHOULDER_NEUTRAL + step_amount);
        k_msleep(delay);
        
        // Plant left side
        servo_set_angle(SERVO_LF_ARM, ARM_DOWN);
        servo_set_angle(SERVO_LB_ARM, ARM_DOWN);
        k_msleep(delay);
        
        // Phase 3: Reset right side back to center
        servo_set_angle(SERVO_RF_ARM, ARM_LIFTED);
        servo_set_angle(SERVO_RB_ARM, ARM_LIFTED);
        k_msleep(delay);
        
        servo_set_angle(SERVO_RF_SHOULDER, SHOULDER_NEUTRAL);
        servo_set_angle(SERVO_RB_SHOULDER, SHOULDER_NEUTRAL);
        k_msleep(delay);
        
        servo_set_angle(SERVO_RF_ARM, ARM_DOWN);
        servo_set_angle(SERVO_RB_ARM, ARM_DOWN);
        k_msleep(delay);
        
    } else {
        /* Walk right - left legs push, right legs pull */
        
        // Phase 1: Lift and move left side out
        servo_set_angle(SERVO_LF_ARM, ARM_LIFTED);
        servo_set_angle(SERVO_LB_ARM, ARM_LIFTED);
        k_msleep(delay);
        
        // Push left side to the left
        servo_set_angle(SERVO_LF_SHOULDER, SHOULDER_NEUTRAL - step_amount);
        servo_set_angle(SERVO_LB_SHOULDER, SHOULDER_NEUTRAL - step_amount);
        k_msleep(delay);
        
        // Plant left side
        servo_set_angle(SERVO_LF_ARM, ARM_DOWN);
        servo_set_angle(SERVO_LB_ARM, ARM_DOWN);
        k_msleep(delay);
        
        // Phase 2: Lift and move right side
        servo_set_angle(SERVO_RF_ARM, ARM_LIFTED);
        servo_set_angle(SERVO_RB_ARM, ARM_LIFTED);
        k_msleep(delay);
        
        // Pull right side inward (body moves right)
        servo_set_angle(SERVO_RF_SHOULDER, SHOULDER_NEUTRAL - step_amount);
        servo_set_angle(SERVO_RB_SHOULDER, SHOULDER_NEUTRAL - step_amount);
        k_msleep(delay);
        
        // Plant right side
        servo_set_angle(SERVO_RF_ARM, ARM_DOWN);
        servo_set_angle(SERVO_RB_ARM, ARM_DOWN);
        k_msleep(delay);
        
        // Phase 3: Reset left side back to center
        servo_set_angle(SERVO_LF_ARM, ARM_LIFTED);
        servo_set_angle(SERVO_LB_ARM, ARM_LIFTED);
        k_msleep(delay);
        
        servo_set_angle(SERVO_LF_SHOULDER, SHOULDER_NEUTRAL);
        servo_set_angle(SERVO_LB_SHOULDER, SHOULDER_NEUTRAL);
        k_msleep(delay);
        
        servo_set_angle(SERVO_LF_ARM, ARM_DOWN);
        servo_set_angle(SERVO_LB_ARM, ARM_DOWN);
        k_msleep(delay);
    }
}

/* Motion execution thread */
static void motion_thread_fn(void *arg1, void *arg2, void *arg3)
{
    ARG_UNUSED(arg1);
    ARG_UNUSED(arg2);
    ARG_UNUSED(arg3);
    
    LOG_INF("Motion thread started");
    
    while (1) {
        if (motion_active) {
            switch (current_motion.direction) {
                case DIR_FORWARD:
                    execute_walk_step(true, current_motion.angle, current_motion.speed);
                    break;
                    
                case DIR_BACKWARD:
                    execute_walk_step(false, current_motion.angle, current_motion.speed);
                    break;
                    
                case DIR_WALK_LEFT:
                    execute_sidestep(true, current_motion.angle, current_motion.speed);
                    break;
                    
                case DIR_WALK_RIGHT:
                    execute_sidestep(false, current_motion.angle, current_motion.speed);
                    break;
                    
                case DIR_STOP:
                    motion_active = false;
                    servo_home_all();
                    break;
                    
                default:
                    motion_active = false;
                    LOG_WRN("Unknown direction: 0x%02X", current_motion.direction);
                    break;
            }
        } else {
            k_msleep(50);
        }
    }
}

/* Initialize motion control */
int motion_init(void)
{
    LOG_INF("Initializing motion control...");
    
    /* Create motion execution thread */
    k_thread_create(&motion_thread, motion_stack,
                    K_THREAD_STACK_SIZEOF(motion_stack),
                    motion_thread_fn,
                    NULL, NULL, NULL,
                    7, 0, K_NO_WAIT);
    
    k_thread_name_set(&motion_thread, "motion");
    
    LOG_INF("✓ Motion control initialized");
    return 0;
}

/* Process motion command */
int motion_process_command(const uint8_t *data, uint16_t len)
{
    if (len < 3) {
        LOG_ERR("Invalid command length: %d (expected 3)", len);
        return -EINVAL;
    }
    
    motion_cmd_t cmd;
    cmd.direction = data[0];
    cmd.angle = data[1];
    cmd.speed = data[2];
    
    LOG_INF("========================================");
    LOG_INF("Motion Command Received:");
    LOG_INF("  Direction: 0x%02X", cmd.direction);
    LOG_INF("  Angle: %d°", cmd.angle);
    LOG_INF("  Speed: %d", cmd.speed);
    LOG_INF("========================================");
    
    /* Validate speed */
    if (cmd.speed < SPEED_SLOW || cmd.speed > SPEED_FAST) {
        LOG_ERR("Invalid speed: %d (must be 1-3)", cmd.speed);
        return -EINVAL;
    }
    
    /* Validate angle */
    if (cmd.angle > 180) {
        LOG_WRN("Angle clamped from %d to 180", cmd.angle);
        cmd.angle = 180;
    }
    
    /* Update current motion */
    current_motion = cmd;
    
    /* Execute based on direction */
    switch (cmd.direction) {
        case DIR_FORWARD:
            LOG_INF("→ MOVING FORWARD (Speed: %d)", cmd.speed);
            motion_active = true;
            break;
            
        case DIR_BACKWARD:
            LOG_INF("→ MOVING BACKWARD (Speed: %d)", cmd.speed);
            motion_active = true;
            break;
            
        case DIR_WALK_LEFT:
            LOG_INF("→ TURNING LEFT (Angle: %d°, Speed: %d)", cmd.angle, cmd.speed);
            motion_active = true;
            break;
            
        case DIR_WALK_RIGHT:
            LOG_INF("→ TURNING RIGHT (Angle: %d°, Speed: %d)", cmd.angle, cmd.speed);
            motion_active = true;
            break;
            
        case DIR_STOP:
            LOG_INF("→ STOP");
            motion_stop();
            break;
            
        default:
            LOG_ERR("Unknown direction code: 0x%02X", cmd.direction);
            return -EINVAL;
    }
    
    return 0;
}

/* Stop all motion */
void motion_stop(void)
{
    LOG_INF("Stopping motion...");
    motion_active = false;
    servo_home_all();
    LOG_INF("✓ Motion stopped");
}

/* Direct motion functions */
int motion_move_forward(uint8_t angle, uint8_t speed)
{
    /* Validate inputs */
    if (speed < SPEED_SLOW || speed > SPEED_FAST) {
        LOG_ERR("Invalid speed: %d", speed);
        return -EINVAL;
    }
    
    LOG_INF("Moving forward - Speed: %d", speed);
    current_motion.direction = DIR_FORWARD;
    current_motion.angle = angle;
    current_motion.speed = speed;
    motion_active = true;
    return 0;
}

int motion_move_backward(uint8_t angle, uint8_t speed)
{
    /* Validate inputs */
    if (speed < SPEED_SLOW || speed > SPEED_FAST) {
        LOG_ERR("Invalid speed: %d", speed);
        return -EINVAL;
    }
    
    LOG_INF("Moving backward - Speed: %d", speed);
    current_motion.direction = DIR_BACKWARD;
    current_motion.angle = angle;
    current_motion.speed = speed;
    motion_active = true;
    return 0;
}

int motion_walk_left(uint8_t angle, uint8_t speed)
{
    /* Validate inputs */
    if (speed < SPEED_SLOW || speed > SPEED_FAST) {
        LOG_ERR("Invalid speed: %d", speed);
        return -EINVAL;
    }
    if (angle > 180) {
        angle = 180;
    }
    
    LOG_INF("Walking left - Angle: %d°, Speed: %d", angle, speed);
    current_motion.direction = DIR_WALK_LEFT;
    current_motion.angle = angle;
    current_motion.speed = speed;
    motion_active = true;
    return 0;
}

int motion_walk_right(uint8_t angle, uint8_t speed)
{
    /* Validate inputs */
    if (speed < SPEED_SLOW || speed > SPEED_FAST) {
        LOG_ERR("Invalid speed: %d", speed);
        return -EINVAL;
    }
    if (angle > 180) {
        angle = 180;
    }
    
    LOG_INF("Walking right - Angle: %d°, Speed: %d", angle, speed);
    current_motion.direction = DIR_WALK_RIGHT;
    current_motion.angle = angle;
    current_motion.speed = speed;
    motion_active = true;
    return 0;
}

/* Special actions */
int motion_wave(void)
{
    LOG_INF("Executing wave gesture");
    
    /* Stop current motion */
    motion_active = false;
    k_msleep(100);
    
    /* Wave with right front leg */
    for (int i = 0; i < 3; i++) {
        servo_set_angle(SERVO_RF_SHOULDER, 45);
        k_msleep(300);
        servo_set_angle(SERVO_RF_SHOULDER, 135);
        k_msleep(300);
    }
    servo_set_angle(SERVO_RF_SHOULDER, 90);
    
    LOG_INF("✓ Wave complete");
    return 0;
}

int motion_test_servos(void)
{
    LOG_INF("========================================");
    LOG_INF("Testing all servos...");
    LOG_INF("========================================");
    
    /* Stop current motion */
    motion_active = false;
    k_msleep(100);
    
    for (int servo = 0; servo < NUM_SERVOS; servo++) {
        LOG_INF("Testing servo %d:", servo);
        
        // Move to 45°
        LOG_INF("  → 45°");
        servo_set_angle(servo, 45);
        k_msleep(500);
        
        // Move to 135°
        LOG_INF("  → 135°");
        servo_set_angle(servo, 135);
        k_msleep(500);
        
        // Return to home
        LOG_INF("  → 90° (home)");
        servo_set_angle(servo, 90);
        k_msleep(300);
    }
    
    LOG_INF("========================================");
    LOG_INF("✓ All servos tested!");
    LOG_INF("========================================");
    
    return 0;
}