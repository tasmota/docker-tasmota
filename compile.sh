#!/bin/bash
CHECK_MARK="\033[0;32m\xE2\x9C\x94\033[0m"
rundir=$(dirname $(readlink -f $0))

## Display chosen builds
echo -e "Running Docker Tasmota for builds:"

## Display builds
if  [ $# -eq 0 ]; then
    echo -e "defined in platformio.ini\n\nNOTICE: \e[31mDefault is ALL BUILDS!!!!\e[0m\n"
    sleep 3
else
    for build in "$@"
    do
        echo -e "$build"
        sleep 1
    done
fi

## fetch newest Tasmota version from development
echo -e "Checking Tasmota GitHub for the most recent development version"
cd `pwd`/Tasmota
git fetch --all 
git reset --hard origin/development 
git pull
cd $rundir

## Check script dir for custom files (platformio.ini or user_config_override.h)
if test -f "platformio.ini"; then
    cp "$rundir"/platformio.ini "$rundir"/Tasmota/platformio.ini
    echo -e "Using your platformio.ini and overwriting the default one"
fi
if test -f "user_config_override.h"; then
    cp "$rundir"/user_config_override.h "$rundir"/Tasmota/tasmota/user_config_override.h
    echo -e "Using your user_config_override.h and overwriting the default one\n"
fi
## Run container with provided arguments
echo -n "Compiling..."
    if  [ $# -ne 0 ]; then
    docker run -it --rm -v `pwd`/Tasmota:/tasmota blakadder/docker-tasmota $(printf ' -e %s' $@) > docker-tasmota.log 2>&1 
else
    docker run -it --rm -v `pwd`/Tasmota:/tasmota blakadder/docker-tasmota > docker-tasmota.log 2>&1 
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
