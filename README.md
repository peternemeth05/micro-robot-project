This repository was created as part of a group project at Imperial College London in the Bioengineering department. It is a control system for micro-robots created by Dr Jayaram.

The repository has two main sections: the app and the backend.

### App Section
The app is written in Dart and uses Flutter, it is broken down into two key sections, lib and test. See below for the folder structure (folder names in bold).

**lib**: contains files for the app, split into:  

--**app_states**: contains the information accessed throughout the app  

--**ble_files**: contains files related to the bluetooth and wifi connection to the robot  
----**services**: contains bluetooth connection classes and related data  
------**ble_connection**: contains classes to manage bluetooth connection  
----**widgets**: bluetooth and wifi widgets (connection buttons etc)  

--**pages**: contains the pages that make up the app  
----**layout_pages**: layout page and base pages for each tab (the following folders are accessed through these base pages)  
----**custom_widgets**: contains custom widgets used in the app  
----**control_pages**: component pages making up robot controls tab  
----**setup_pages**: component pages for the robot set up page  

**test**: contains unit test files

### Backend Section
The backend is written in Zephyr Real Time Operating System(RTOS) and connects directly to the robot board (ESP-32). See below for the folder structure

**src:** contains the source code files for the firmware, which is split into:

--**main.c:** main application entry point and initialises all the different systems (modules) and handles bluetooth command processing

--**bluetooth:** contains GATT services, connection manaement and pairing logic for the bluetooth connection and recieving commands from the app

--**wifi_server:** establishes two different ways to connect to wifi. STA or AP mode

--**ultrasonic.c:** HC-SR04 ultrasonic sensor driver for distance measurement to be fed into the app

--**servo_control:** PCA9685I2C servo controller driver for 12 shoulder to control the movement of each servo. 

--**motion_control.c:** motion control implementing walking gaits (forward, backward, left right)

------*wifi_server.c, servo_control.c and motion control.c could not be implemented due to errors when working in Zephyr. Software issure not hardware since it works in Arduino which is not our intended IDE.*------

**esp32_devkitc_procpu.overlay:** device tree overlay defining pin assignments and board-specific configurations

**prj.conf:**: project configuration file to enable bluetooth, Wi-Fi, GPIO and many more.

**CMakeLists.txt:**: build system configurations which lists source files to compile.




