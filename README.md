This repository was created as part of a group project at Imperial College London in the Bioengineering department. It is a control system for micro-robots created by Dr Jayaram.

The repository has two main sections: the app and the backend.

The app is written in Dart and uses Flutter, it is broken down into two key sections:
  lib folder: contains files for the app
    this is split into:
      app_states: contains the information accessed throughout the app
      ble_files: contains files related to the bluetooth connection to the robot (including bluetooth connection buttons and data)
      pages: contains the pages that make up the app split into:
        layout_pages: layout page and base pages for each tab (the following folders are accessed through these base pages)
        controls_pages: components pages making up robot controls tab
        sensor_pages: components making up sensor data and plotting in robot controls tab
        setup_pages: components for the robot set up page
  test folder: contains test files

  The backend is written in zephyr and connects directly to the robot board (ESP-32).
