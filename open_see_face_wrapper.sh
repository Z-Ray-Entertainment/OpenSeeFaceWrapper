#!/bin/bash
PID=$$
SCRIPT_NAME=$0
NO_UI="false"

ZENTIY="zenity"
OPEN_SEE_FACE_URL="https://github.com/emilianavt/OpenSeeFace.git"
ISSUE_URL="https://github.com/VortexAcherontic/OpenSeeFaceWrapper/issues"

open_see_face_cloned="FALSE"
deps_installed="TRUE"

declare -a dependencies=("git" "python3" "virtualenv" "pip")
declare -A dep_map_zypper
dep_map_zypper["git"]="git"
dep_map_zypper["python3"]="python3"
dep_map_zypper["virtualenv"]="python3-virtualenv"
dep_map_zypper["pip"]="python3-pip"
dep_map_zypper["zenity"]="zenity"

declare -A dep_map_zypper_tumbleweed
dep_map_zypper_tumbleweed["git"]="git"
dep_map_zypper_tumbleweed["python3"]="python3"
dep_map_zypper_tumbleweed["virtualenv"]="python310-virtualenv"
dep_map_zypper_tumbleweed["pip"]="python310-pip"
dep_map_zypper_tumbleweed["zenity"]="zenity"

declare -A dep_map_apt
dep_map_apt["git"]="git"
dep_map_apt["python3"]="python3"
dep_map_apt["virtualenv"]="python3-virtualenvwrapper"
dep_map_apt["pip"]="pip"
dep_map_apt["zenity"]="zenity"

declare -A dep_map_dnf
dep_map_dnf["git"]="git"
dep_map_dnf["python3"]="python3"
dep_map_dnf["virtualenv"]="python3-virtualenvwrapper"
dep_map_dnf["pip"]="pip"
dep_map_dnf["zenity"]="zenity"

declare -A dep_map_pacman
dep_map_pacman["git"]="git"
dep_map_pacman["python3"]="python3"
dep_map_pacman["virtualenv"]="python3-virtualenvwrapper"
dep_map_pacman["pip"]="pip"
dep_map_pacman["zenity"]="zenity"

if [ "$1" == "--no-ui" ]; then
    NO_UI="TRUE"
fi

test_binary() {
    which $1 2>/dev/null || echo FALSE
}

install_apt(){
    $1 "apt -y update"
    $1 "apt -y upgrade"
    $1 "apt -y install $2"
}

install_zypper(){
    $1 "zypper in -y $2"
}

install_dnf(){
    echo "dnf"
}

install_yum(){
    echo "yum"
}

install_pacman(){
    $1 "\"pacman -Syu $2\""
}

run_in_terminal(){
    test_gnome_terminal=$(test_binary "gnome-terminal")
    test_konsole=$(test_binary "konsole")
    test_xfce_terminal=$(test_binary "xfce4-terminal")
    test_lxterminal=$(test_binary "lxterminal")
    test_xterm=$(test_binary "xterm")
    test_alacritty=$(test_binary "alacritty")

    if [ $test_gnome_terminal == "TRUE" ]; then
        gnome-terminal --tab -- "$PWD/$SCRIPT_NAME --no-ui"
    elif [ $test_konsole == "TRUE" ]; then
        konsole -e "$PWD/$SCRIPT_NAME --no-ui"
    elif [ $test_xfce_terminal == "TRUE" ]; then
        echo "xfce terminal"
    elif [ $test_lxterminal == "TRUE" ]; then
        echo "lxterminal"
    elif [ $test_xterm == "TRUE" ]; then
        echo "xterm"
    elif [ $test_alacritty == "TRUE" ]; then
        echo "alacritty"
    else
        if [ "$NO_UI" == "TRUE" ]; then
            echo "I was not able to identify your terminal emulator. Please run this script manually from a terminal session."
        else
            $ZENTIY --title "OpenSeeFace Wrapper" --info --text "I was not able to identify your terminal emulator. Please run this script manually from a terminal session."
        fi
    fi
}

test_su_tool(){
    if [ "$NO_UI" == "TRUE" ]; then
        echo "sudo"
    else
        test_xdgsu=$(test_binary "xdg-su")
        test_kdesu=$(test_binary "kdesu")
        test_gnomesu=$(test_binary "gnomesu")


        if [ $test_xdgsu != "FALSE" ]; then
            echo "xdg-su -u root -c"
        elif [ $test_kdesu != "FALSE" ]; then
            echo "kdesu -c"
        elif [ $test_gnomesu != "FALSE" ]; then
            echo "gnomesu -c"
        else
            $ZENTIY --title "OpenSeeFace Wrapper" --info --text "It seems there is no UI based root password confirmation dialog available on your system. \
            I'll try to run this script from a terminal session."
            run_in_terminal
        fi
    fi
}

get_distro_name(){
    echo $(awk -F= '$1=="PRETTY_NAME" { print $2 ;}' /etc/os-release)
}

install_dependency(){
    dependency=$1
    test_su_tool=$(test_su_tool)
    test_apt=$(test_binary "apt")
    test_zypper=$(test_binary "zypper")
    test_dnf=$(test_binary "dnf")
    test_yum=$(test_binary "yum")
    test_pacman=$(test_binary "pacman")


    if [ $test_apt != "FALSE" ]; then
        install_apt "$test_su_tool" "${dep_map_apt[$dependency]}"
    elif [ $test_zypper != "FALSE" ]; then
        distro_name=$(get_distro_name)
        if [ "$distro_name" == *"Leap"* ]; then
            install_zypper "$test_su_tool" "${dep_map_zypper[$dependency]}"
        else
            install_zypper "$test_su_tool" "${dep_map_zypper_tumbleweed[$dependency]}"
        fi
    elif [ $test_dnf != "FALSE" ]; then
        install_dnf "$test_su_tool" "${dep_map_dnf[$dependency]}"
    elif [ $test_yum != "FALSE" ]; then
        install_yum "$test_su_tool" "${dep_map_dnf[$dependency]}"
    elif [ $test_pacman != "FALSE" ]; then
        install_pacman "$test_su_tool" "${dep_map_pacman[$dependency]}"
    else
        echo "There seems to be no supported package manager installed on your system."
        echo "Please open an issue at: $ISSUE_URL"
    fi
}

check_and_install_dependencies(){
    for i in "${dependencies[@]}"
    do
        test_result=$(test_binary $i)
        if [ $test_result == "FALSE" ]; then
            $ZENTIY --title "OpenSeeFace Wrapper" --question --text "It seems $i is not installed on your system. Do you want me to install it for you?"
            install_confimed=$?
            if [ $install_confimed -eq 0 ]; then
                install_dependency $i
                if [ "$NO_UI" == "TRUE" ]; then
                    echo "$i was installed on to your system, continue."
                else
                    $ZENTIY --title "OpenSeeFace Wrapper" --info --text "$i was installed on to your system, continue."
                fi
            else
                if [ "$NO_UI" == "TRUE" ]; then
                    echo "Alright, I am exiting now and will not install OpenSeeFace or any of it's dependecies. Have a great day!"
                else
                    $ZENTIY --title "OpenSeeFace Wrapper" --info --text "Alright, I am exiting now and will not install OpenSeeFace or any of it's dependecies. Have a great day!"
                fi
                kill $PID
            fi
        fi
    done
}

test_and_install_zentiy(){
    if [ "$NO_UI" == "FALSE" ]; then
        test_zenity=$(test_binary "$ZENTIY")
        if [ $test_zenity == "FALSE" ]; then
            install_dependency "$ZENTIY"
        fi
    fi
}

is_installation_complete(){
    if [ -d "$PWD/OpenSeeFace" ]; then
        open_see_face_cloned="TRUE"
    fi

    for i in "${dependencies[@]}"
    do
        test_result=$(test_binary $i)
        if [ $test_result == "FALSE" ]; then
            deps_installed="FALSE"
        fi
    done

    if [ $open_see_face_cloned == "TRUE" ] && [ $deps_installed == "TRUE" ]; then
        echo "TRUE"
    else
        echo "FALSE"
    fi
}

clone_open_see_face(){
    if [ $open_see_face_cloned == "FALSE" ]; then
        $ZENTIY --title "OpenSeeFace Wrapper" --question --text "It seems OpenSeeFace is not installed on your system. Do you want me to install it for you?"
        install_confimed=$?
        if [ $install_confimed -eq 0 ]; then
            git clone $OPEN_SEE_FACE_URL
        else
            $ZENTIY --title "OpenSeeFace Wrapper" --info --text "Alright, I am exiting now and will not install OpenSeeFace or any of it's dependecies. Have a great day!"
            kill $PID
        fi

    fi
}

setup_open_see_face(){
    cd "./OpenSeeFace"
    virtualenv -p python3 "$PWD/env"
    source "$PWD/env/bin/activate"
    pip install onnxruntime opencv-python pillow numpy
    cd "../"
}

run_open_see_face(){
    cd "./OpenSeeFace"
    virtualenv -p python3 "$PWD/env"
    source "$PWD/env/bin/activate"
    python facetracker.py -c 0 -W 640 -H 480 --discard-after 0 --scan-every 0 --no-3d-adapt 1 --max-feature-updates 900 -s 1 --port 20202 &
    pid_osf=${!}
    $ZENTIY --title "OpenSeeFace Wrapper" --info --text "OpenSeeFace is now running. Close this window to also stop OpenSeeFace."
    kill $pid_osf
    kill $PID
}

install_complete=$(is_installation_complete)
if [ $install_complete == "TRUE" ]; then
    test_and_install_zentiy
    run_open_see_face
else
    test_and_install_zentiy
    $ZENTIY --title "OpenSeeFace Wrapper" --info --text "Welcome to OpenSeeFace Wrapper, this tool will install and run OpenSeeFace for you"
    check_and_install_dependencies
    clone_open_see_face
    setup_open_see_face
    run_open_see_face
fi