# OpenSeeFaceWrapper
A UI based shell script to downalod, setup and run OpenSeeFace on Linux with just a simple click.

## Usage
* Download the open_see_face_wrapper script to your computer
* Mark the file as executable
* Run

## How it works
The script will first check if you have zenity installed on your system as it is used for the UI based installer.  

If zenity is missing the script installes it via your native packagemanager.  
For this it queries which UI based sudo authentication dialog your system suppots.  
Currently it tests for:  
* xdg-su  
* kdesu  
* gnomesu

When installing packages it also queries the native package manager of your system.  
Currently supported are:  
* zypper

Currently in the works are:  
* apt  
* dnf  
* yum  
* pacman

Planed for future version if required:  
* emerge (Gentoo)  
* transactional-update (openSUSE MicroOS)

In order to run OpenSeeFace and the script itself it will install the following packages if missing:  
* git  
* python3  
* virtualenv  
* pip  
* zentiy