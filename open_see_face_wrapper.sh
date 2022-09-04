#!/bin/bash
ZENTIY="zenity"
OPEN_SEE_FACE_URL="https://github.com/emilianavt/OpenSeeFace.git"

open_see_face_cloned="FALSE"
deps_installed="TRUE"

declare -a dependencies=("git" "python3" "virtualenv" "pip")

test_binary() {
    which $1 2>/dev/null || echo FALSE
}

install_apt(){
    $1 "\"apt update -y\""
    $1 "\"apt upgrade -y\""
    $1 "\"apt install -y $2\""
}

install_zypper(){
    $1 "\"zypper in -y $2\""
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

test_sudo(){
    test_xdgsu=$(test_binary "xdg-su")
    test_kdesu=$(test_binary "kdesu")
    test_gnomesu=$(test_binary "gnomesu")


    if [ $test_xdgsu != "FALSE" ]; then
        echo "xdg-su -u root -c"
    elif [ $test_kdesu != "FALSE" ]; then
        echo "kdesu -c"
    elif [ $test_gnomesu != "FALSE" ]; then
        echo "gnomesu -c"
    fi
}

install_dependency(){
    dependency=$1
    test_su_tool=$(test_sudo)
    test_apt=$(test_binary "apt")
    test_zypper=$(test_binary "zypper")
    test_dnf=$(test_binary "dnf")
    test_yum=$(test_binary "yum")
    test_pacman=$(test_binary "pacman")


    if [ $test_apt != "FALSE" ]; then
        install_apt "$test_su_tool" "$dependency"
    elif [ $test_zypper != "FALSE" ]; then
        install_zypper "$test_su_tool" "$dependency"
    elif [ $test_dnf != "FALSE" ]; then
        install_dnf "$test_su_tool" "$dependency"
    elif [ $test_yum != "FALSE" ]; then
        install_yum "$test_su_tool" "$dependency"
    elif [ $test_pacman != "FALSE" ]; then
        install_pacman "$test_su_tool" "$dependency"
    else
        echo "There seems to be no supported pakage manager installed on your system."
        echo "Please open an issue at: https://github.com/VortexAcherontic/OpenSeeFaceWrapper/issues"
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
            else
                $ZENTIY --title "OpenSeeFace Wrapper" --info --text "Alright, I am exiting now and will not install OpenSeeFace or any of it's dependecies. Have a great day!"
            fi
        fi
    done
}

test_and_install_zentiy(){
    test_zenity=$(test_binary "$ZENTIY")
    if [ $test_zenity == "FALSE" ]; then
        install_dependency "$ZENTIY"
    fi
}

is_installation_complete(){
    if [ -d "OpenSeeFace" ]; then
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
    $ZENTIY --title "OpenSeeFace Wrapper" --info --text "OpenSeeFace is now running. Close this window to also stop OpenSeeFace."
    kill 0
}

install_complete=$(is_installation_complete)
if [ $install_complete == "TRUE" ]; then
    test_and_install_zentiy
    run_open_see_face
else
    $ZENTIY --title "OpenSeeFace Wrapper" --info --text "Welcome to OpenSeeFace Wrapper, this tool will install and run OpenSeeFace for you"
    check_and_install_dependencies
    clone_open_see_face
    setup_open_see_face
    run_open_see_face
fi