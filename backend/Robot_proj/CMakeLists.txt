# Minimum CMake version required
cmake_minimum_required(VERSION 3.20.0)

#set(BOARD esp_wrover_kit/esp32/procpu CACHE STRING "Board name")

# Find the Zephyr package (required for all Zephyr projects)
find_package(Zephyr REQUIRED HINTS $ENV{ZEPHYR_BASE})

# Define the project name
project(Robot_proj)

# Add the source files to the application
target_sources(app PRIVATE
    src/main.c
    src/bluetooth.c
    #src/wifi_server.c
)