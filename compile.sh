#!/bin/bash

# Copy this bash script to a directory below /Tasmota and run from there

CHECK_MARK="\033[0;32m\xE2\x9C\x94\033[0m"
rundir=$(dirname $(readlink -f $0))

## Check whether Tasmota/ exists and fetch newest Tasmota version from development branch
if test -d `pwd`"/Tasmota"; then
    echo -e "Downloading latest Tasmota version from GitHub"
    cd Tasmota
    rm build_output/firmware/* > /dev/null
#    git fetch --all
#    git reset --hard origin/development > /dev/null
    git stash  > /dev/null
    git pull
    cd $rundir
    echo -e "\nRunning Docker Tasmota\n"
    # Check if docker installed
    if [[ "$(type -t docker)" == "file" ]] ; then
        ## Display builds
        if  [ $# -eq 0 ]; then
            ## Check script dir for platformio_override.ini
            if test -f "platformio_override.ini"; then
                echo -e "Compiling builds defined in platformio_override.ini. Existing file is overwritten.\n"
                cp platformio_override.ini Tasmota/platformio_override.ini
                else
                echo -e "\e[31mCompiling ALL BUILDS using default platformio.ini!!!!\n\n\e[7mIf you wish to quit use ctrl+C\e[0m"
                sleep 5
            fi
            else
                ## Display chosen builds
                echo -e "Compiling builds:"
                for build in "$@"
                do
                    echo -e "$build"
                    sleep 1
                done
                echo -e "\n"
        fi
        ## Check script dir for custom user_config_override.h
        if test -f "user_config_override.h"; then
            # sed -i 's/^; *-DUSE_CONFIG_OVERRIDE/                            -DUSE_CONFIG_OVERRIDE/' Tasmota/platformio.ini
            cp user_config_override.h Tasmota/tasmota/user_config_override.h
            echo -e "Using local user_config_override.h and overwriting the existing one\n"
        fi
        ## Run container with provided arguments
        echo -n "Compiling..."
	test -t 1 && DOCKER_TTY="-it"
        if  [ $# -ne 0 ]; then
                if [[ $@ == "tasmota"* ]]; then
                    docker run ${DOCKER_TTY} --rm -v `pwd`/Tasmota:/tasmota -u $UID:$GID $DOCKER_IMAGE $(printf ' -e %s' $@) > docker-tasmota.log 2>&1 
                    echo -e "\\r${CHECK_MARK} Finished!  \tCompilation log in docker-tasmota.log\n"
                    else
                    echo -e "\\r\e[31mNot a valid buildname.\e[0m Try one of the builds:\ntasmota\t\ttasmota-minimal\ttasmota-lite\ttasmota-ircustom\ntasmota-knx\ttasmota-sensors\ttasmota-display\ttasmota-ir\nFor translated builds:\ntasmota-BG [BR,CN,CZ,DE,ES,FR,GR,HE,HU,IT,KO,NL,PL,PT,RU,SE,SK,TR,TW,UK]"
                    exit 1
                fi
            else
            docker run ${DOCKER_TTY} --rm -v `pwd`/Tasmota:/tasmota -u $UID:$GID $DOCKER_IMAGE > docker-tasmota.log 2>&1 
            echo -e "\\r${CHECK_MARK} Finished! \tCompilation log in docker-tasmota.log\n"
            echo -e "Find your builds in $rundir/Tasmota/build_output/firmware\n"
        fi
        ## After docker is completed copy firmware to script dir and rename to buildname
        for build in "$@"
        do
        cp "$rundir"/Tasmota/build_output/firmware/"$build".* "$rundir"
            if test -f "$build".bin; then
                echo -e "Completed! Your firmware is in $rundir\n"
            else
                echo -e "\e[31m\e[5mWARNING:\e[0m"
                echo -e "Something went wrong while compiling $build. Check compilation log\n"
            fi  
        done
    else
        echo -e "\nNo Docker detected. Please install docker:\n\n\tcurl -fsSL https://get.docker.com -o get-docker.sh\n\tsh get-docker.sh\n"
        # fi
    fi
else
    if [[ "$(type -t git)" == "file" ]] ; then
        echo -e "\nNo Tasmota Git repository found in directory.\nDo you wish to clone Tasmota GitHub repository to current directory?"
        read -p "Enter to exit, "yes" to proceed: " answer
            case ${answer:0:1} in
                y|yes )
                    git clone --no-single-branch --depth 1 https://github.com/arendst/Tasmota.git
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

