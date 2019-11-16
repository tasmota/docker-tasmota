#!/bin/bash

# Copy this bash script to a directory below /Tasmota and run from there

CHECK_MARK="\033[0;32m\xE2\x9C\x94\033[0m"
rundir=$(dirname $(readlink -f $0))

## Check whether Tasmota/ exists and fetch newest Tasmota version from development branch
if test -d `pwd`"/Tasmota"; then
    echo -e "Checking Tasmota GitHub for the most recent development version"
    cd Tasmota
    git fetch --all
    git reset --hard origin/development
    git pull
    cd $rundir
    # Check if docker installed
    if [[ "$(type -t docker)" == "file" ]] ; then
        ## Display chosen builds
        echo -e "Running Docker Tasmota for builds:"
        ## Display builds
        if  [ $# -eq 0 ]; then
            echo -e "defined in platformio.ini\n\nNOTICE: \e[31mDefault is ALL BUILDS!!!!\e[0m\nIf you want to quit use ctrl+C"
            sleep 3
            else
                for build in "$@"
                do
                    echo -e "$build"
                    sleep 1
                done
        fi

        ## Check script dir for custom platformio.ini or user_config_override.h
        if test -f "platformio.ini"; then
            cp platformio.ini Tasmota/platformio.ini
            echo -e "Using your platformio.ini and overwriting the default file"
        fi
        if test -f "user_config_override.h"; then
            cp user_config_override.h Tasmota/tasmota/user_config_override.h
            echo -e "Using your user_config_override.h and overwriting the default file\n"
        fi
        ## Run container with provided arguments
        echo -n "Compiling..."
        if  [ $# -ne 0 ]; then
            docker run -it --rm -v `pwd`/Tasmota:/tasmota -u $UID:$GID blakadder/docker-tasmota $(printf ' -e %s' $@) > docker-tasmota.log 2>&1 
            else
            docker run -it --rm -v `pwd`/Tasmota:/tasmota -u $UID:$GID blakadder/docker-tasmota > docker-tasmota.log 2>&1 
            echo "Find your builds in .pioenvs/<build-flavour>/firmware.bin"
        fi
        echo -e "\\r${CHECK_MARK} Finished!  \tCompilation log in docker-tasmota.log\n"
        ## After docker is completed copy firmware to script dir and rename to buildname
        for build in "$@"
        do
        cp "$rundir"/Tasmota/.pioenvs/"$build"/firmware.bin "$rundir"/"$build".bin
            if test -f "$build".bin; then
                echo -e "Completed! Your firmware is $rundir/$build.bin\n"
            else
                echo -e "\e[31m\e[5mWARNING:\e[0m"
                echo -e "Something went wrong while compiling $build. Check compilation log\n"
            fi  
        done
    else
        if [[ "$(type -t curl)" != "file" ]] ; then
            echo -e "Please install "curl" to proceed"
            exit 1
        else
        echo -e "\nNo Docker detected. Please install docker:\n\n\tcurl -fsSL https://get.docker.com -o get-docker.sh\n\tsh get-docker.sh\n"
        fi
    fi
else
    if [[ "$(type -t git)" == "file" ]] ; then
        echo -e "\nNo Tasmota Git repository found in directory.\nDo you wish to clone Tasmota GitHub repository to current directory?"
        read -p "Enter to exit, "yes" to proceed: " answer
            case ${answer:0:1} in
                y|yes )
                    git clone https://github.com/arendst/Tasmota.git
                    bash $(basename $0) && exit   
                ;;
                * )
                    exit 1
                ;;
            esac
    else
        echo -e "\nPlease install "git" to proceed:\n\n\tDebian/Ubuntu/Mint:\tsudo apt-get install git\n\tFedora:\t\t\tsu -c 'yum install git'\n\topenSUSE:\t\tsudo zypper in git\n"
        exit 1
    fi
fi
