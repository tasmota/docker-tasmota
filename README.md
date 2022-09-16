# Docker-Tasmota
Quickly set up a build environment for [Tasmota](https://github.com/arendst/Tasmota) using Docker

## compile.sh
This bash script makes compiling a lot easier without the need to type lengthy commands each time.

compile.sh is intended to run on a linux machine with docker and git installed. If you're missing any of these the script will pop a warning with instructions how to install.

Running the script for the first time will pull the latest blakadder/docker-tasmota container (you can edit the script to use your own docker container), clone the latest Tasmota development branch (you can change to clone the latest stable release version by setting `USE_STABLE=1`) inside the script folder and copy platformio_override.ini and user_config_override.h to Tasmota folder.

Running the script with one or more build names (as listed in platformio_tasmota_ev.ini) as parameters will compile only those builds regardless of platformio.ini or platformio_override.ini

`./compile.sh tasmota-sensors tasmota-PT`    
compiles both the tasmota-sensors.bin and the portuguese language version of Tasmota

If you have a `user_config_override.h` or `platformio_override.ini` file with your custom settings you can put them in the script folder and they will be used on the next script run. 

Script will update the repo folder with the latest one every run.

To check compiling logs use `cat docker-tasmota.log`

## How to use the docker container
1. Clone this repo and cd to the dir where its cloned:    
    ```
    git clone https://github.com/tasmota/docker-tasmota
    cd docker-tasmota
    ```

2. Run this to build the docker container:
    `docker build -t docker-tasmota .`

   1. _Instead of 1. and 2:_ you can grab the latest docker image with `docker pull blakadder/docker-tasmota`

3. Move to a directory where you want to clone Tasmota repo:
    ```
    git clone https://github.com/arendst/Tasmota.git
    ```

If you have a `user_config_override.h` or `platformio_override.ini` file with your custom settings, you will need to put them under `Tasmota/tasmota`.

4. From the same directory run to compile the desired build   
`docker run -ti --rm -v $(pwd)/Tasmota:/tasmota -u $UID:$GID docker-tasmota -e tasmota-PT`

> `-e <buildname>` where <buildname> can be any of the [builds listed in platformio.ini](https://github.com/arendst/Tasmota/blob/063611314777d4dd9dc8c25905f19f8b25f510aa/platformio.ini#L18). If you don't define a build then ***every*** build will get compiled.

5. When compiling finishes you should have the compiled binary and gzipped version in `Tasmota/build_output/firmware` which can be flashed on your devices.

## Switch branch other than development

`cd Tasmota`

List branches with `git branch -a`

Switch to release branch with

`git checkout release`

Build it and run:
```docker
docker run -ti --rm \
-v $(pwd)/Tasmota:/tasmota \
-u $UID:$GID docker-tasmota
```

