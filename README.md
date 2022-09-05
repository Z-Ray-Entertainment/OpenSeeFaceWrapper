# OpenSeeFaceWrapper
A UI based shell script to downalod, setup and run OpenSeeFaces Facetracker on Linux for the likes of VTube Studio with just a simple click.

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
* apt

Currently in the works are:    
* dnf  
* yum  
* pacman

Planed for future version if required:  
* emerge (Gentoo)  
* transactional-update (openSUSE MicroOS)

### Requirements which get installed
In order to run OpenSeeFace and the script itself it will install the following packages if missing:  
* git  
* python3  
* virtualenv  
* pip  
* zenity

## Distribution support
### Working
This script was tested and found working on the following distributions  
* openSUSE Tumbleweed  
* openSUSE Leap 15.4  

### Under development
The script is currently being adjusted to work with the following Distributions:  
* Debian 11 (see Issue [#5](https://github.com/VortexAcherontic/OpenSeeFaceWrapper/issues/5))

### Planed
The script is planed to be also adjusted for the following distributions:  
* Fedora 36 (Issue [#7](https://github.com/VortexAcherontic/OpenSeeFaceWrapper/issues/7))  
* EndevourOS (Issue [#6](https://github.com/VortexAcherontic/OpenSeeFaceWrapper/issues/6))  
* Ubuntu 22.04 LTS (Issue [#8](https://github.com/VortexAcherontic/OpenSeeFaceWrapper/issues/8))  

If your distribution is based on something of the above the script should work there as well.