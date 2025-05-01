Moon Patrol for MEGA65
=======================

Moon Patrol is a classic side scrolling shooter released in 1982 by Irem, with Williams Electronics handling its North American distribution. The game is credited with introducing parallax scrolling, a technique that added depth to 2D backgrounds. Players control a lunar rover, navigating rough terrain while jumping over craters and shooting enemy UFOs. The game features two courses, each divided into 26 checkpoints, with major checkpoints marking new stages. Its unique blend of platforming and shooting mechanics made it a standout in early arcade gaming

This core is based on the
[Arcade-MoonPatrol_MiSTer](https://github.com/MiSTer-devel/Arcade-MoonPatrol_MiSTer)
Moon Patrol itself is based on the wonderful work of [sorgelig](AUTHORS) and others.

The core uses the [MiSTer2MEGA65](https://github.com/sy2002/MiSTer2MEGA65)
framework and [QNICE-FPGA](https://github.com/sy2002/QNICE-FPGA) for
FAT32 support (loading ROMs, mounting disks) and for the
on-screen-menu.

How to install on your MEGA65
---------------------------------------------
Download the powershell or shell script from the **CORE** directory depending on your preferred platform ( Windows, Linux/Unix and MacOS supported )

Run the script: a) First extract all the files within the zip to any working folder.

b) Copy the powershell or shell script to the same folder and execute it to create the following files.

**Ensure the following files are present and sizes are correct**  

 ![image](https://github.com/user-attachments/assets/086bcade-5926-4554-81ae-7ba2e05147fb)


For Windows run the script via PowerShell - mpatrol_rom_installer.ps1  
Simply select the script and with the right mouse button select the Run with Powershell.

For Linux/Unix/MacOS execute ./mpatrol_rom_installer.sh  
The script will automatically create the /arcade/mpatrol folder where the generated ROMs will reside.  

The output produced as a result of running the script(s) from the cmd line should match the following depending on your target platform.
![image](https://github.com/user-attachments/assets/ee3273be-1c6c-440c-a473-b9312bc4ccbd)


Copy or move "arcade/mpatrol" to your MEGA65 SD card: You may either use the bottom SD card tray of the MEGA65 or the tray at the backside of the computer (the latter has precedence over the first).  
