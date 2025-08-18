#!/bin/bash

# Copy this bash script to a directory below /Tasmota and run from there

CHECK_MARK="\033[0;32m\xE2\x9C\x94\033[0m"
rundir=$(dirname $(readlink -f $0))

# use default docker-tasmota image from hub.docker.com
DOCKER_IMAGE=${DOCKER_IMAGE:="blakadder/docker-tasmota"}
# uncomment and change if you want to run a locally built image
# or set DOCKER_IMAGE as environment variable before starting this script
#DOCKER_IMAGE=docker-tasmota

# Set to `1=true` to use latest stable release tag
# Set to `0=false` to use `development` branch (default)
USE_STABLE=${USE_STABLE:="0"}

USE_VOLUME=${USE_VOLUME:="`pwd`/Tasmota"}

## Check whether Tasmota/ exists and fetch newest Tasmota version from development branch
if test -d "`pwd`/Tasmota"; then
    cd Tasmota
    git fetch https://github.com/arendst/Tasmota.git development
    git fetch --all --tags
    if [ "$USE_STABLE" = "1" ]; then
        if [ -z "${TASMOTA_BRANCH}" ]; then
            echo -e "Checking Tasmota GitHub for the most recent release version"
            TASMOTA_BRANCH=$(curl -s https://api.github.com/repos/arendst/Tasmota/releases/latest | grep -oE '"tag_name"[[:space:]]*:[[:space:]]*"[^"]+"' | cut -d'"' -f4)
        else
            echo -e "getting version \"${TASMOTA_BRANCH}\" from GitHub"
        fi
        git checkout --force $TASMOTA_BRANCH >/dev/null 2>&1
    else
        echo -e "Checking Tasmota GitHub for the most recent development version"
        TASMOTA_BRANCH=development
        git reset --hard origin/$TASMOTA_BRANCH > /dev/null 2>&1
        git pull origin $TASMOTA_BRANCH > /dev/null 2>&1
    fi

    if [ -z "$TASMOTA_BRANCH" ]; then
        echo -e "Failed to fetch/set Tasmota branch! Check internet connection and try again."
        exit 1
    fi

    cd $rundir
    echo -e "\nRunning Docker Tasmota on Tasmota version $TASMOTA_BRANCH\n"
    # Check if docker installed
    if [[ "$(type -t docker)" == "file" ]] ; then
        ## Display builds
        if  [ $# -eq 0 ]; then
            ## Check script dir for platformio_override.ini
            if test -e "platformio_override.ini"; then
                echo -e "Compiling builds defined in platformio_override.ini. Default file is overwritten.\n"
                cp platformio_override.ini Tasmota/platformio_override.ini
                else
                echo -e "\e[31mCompiling ALL BUILDS!!!!\n\n\e[7mIf you wish to quit use ctrl+C\e[0m"
                sleep 4
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
        if test -e "user_config_override.h"; then
        ## new Tasmota builds have this enabled as default
        ##    sed -i 's/^; *-DUSE_CONFIG_OVERRIDE/                            -DUSE_CONFIG_OVERRIDE/' Tasmota/platformio.ini
            cp user_config_override.h Tasmota/tasmota/user_config_override.h
            echo -e "Using your user_config_override.h and overwriting the existing file\n"
        fi
        ## Run container with provided arguments
        echo -n "Compiling..."
        test -t 1 && DOCKER_TTY="-it"
        if [ $# -ne 0 ]; then
            if [[ $@ == "tasmota"* ]]; then
                if [ "${USE_TEE}" = "1" ]; then
                    docker run ${DOCKER_TTY} --rm -v "${USE_VOLUME}":/tasmota -e HOST_UID=$UID -e HOST_GID=$GID $DOCKER_IMAGE $(printf ' -e %s' $@) 2>&1 | tee ${TEE_PARAMETER} docker-tasmota.log
                else
                    docker run ${DOCKER_TTY} --rm -v "${USE_VOLUME}":/tasmota -e HOST_UID=$UID -e HOST_GID=$GID $DOCKER_IMAGE $(printf ' -e %s' $@) 2>&1 > docker-tasmota.log
                fi
                echo -e "\\r${CHECK_MARK} Finished!  \tCompilation log in docker-tasmota.log\n"
            else
                echo -e "\\r\e[31mNot a valid build environment."
                exit 1
            fi
        else
            if [ "${USE_TEE}" = "1" ]; then
                docker run ${DOCKER_TTY} --rm -v "${USE_VOLUME}":/tasmota -e HOST_UID=$UID -e HOST_GID=$GID $DOCKER_IMAGE 2>&1 | tee ${TEE_PARAMETER} docker-tasmota.log
            else
                docker run ${DOCKER_TTY} --rm -v "${USE_VOLUME}":/tasmota -e HOST_UID=$UID -e HOST_GID=$GID $DOCKER_IMAGE 2>&1 > docker-tasmota.log
            fi
            echo -e "\\r${CHECK_MARK} Finished! \tCompilation log in docker-tasmota.log\n"
            echo -e "Find your builds in $rundir/Tasmota/build_output/firmware\n"
        fi
        ## After docker is completed copy firmware to script dir and rename to buildname
        for build in "$@"
        do
        cp "$rundir"/Tasmota/build_output/firmware/"$build"* "$rundir"/
            if test -e "$build".bin; then
                echo -e "Completed! Your firmware is in $rundir/$build.bin\n"
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
                    git clone https://github.com/arendst/Tasmota.git --branch development
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
