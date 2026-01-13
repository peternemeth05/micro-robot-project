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
The backend is written in zephyr and connects directly to the robot board (ESP-32).
