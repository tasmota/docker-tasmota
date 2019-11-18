# Docker-Tasmota
Quickly set up a build environment for [Tasmota](https://github.com/arendst/Tasmota) using Docker

## compile.sh
This bash script makes compiling a lot easier without the need to type lengthy commands each time.

compile.sh is intended to run on a linux machine with docker and git installed. If you're missing any of these the script will pop a warning with instructions how to install.

Running the script for the first time will pull the latest blakadder/docker-tasmota container, clone the latest development branch of Tasmota inside the script folder and start building ALL builds as defined in platformio.ini.

Running the script with one or more build names (as listed in platformio.ini) as parameters will compile only those builds regardless of platformio.ini

`./compile.sh tasmota-sensors tasmota-PT`    
compiles both the tasmota-sensors.bin and the portuguese language version of Tasmota

If you have a `user_config_override.h` or `platformio.ini` file with your custom settings you can put them in the script folder and they will be used on the next script run. 

Script will update the repo folder with the latest one every run.

To check compiling logs use `cat docker-tasmota.log`

## How to use the docker container
1. Clone this repo and cd to the dir where its cloned:    
    `git clone https://github.com/tasmota/docker-tasmota`      
    `cd docker-tasmota`   
    `cd Tasmota`   

2. Run this to build the docker container:   
`docker build -t docker-tasmota .`

   1. _Instead of 1. and 2:_ grab the docker image with `docker pull blakadder/docker-tasmota`

3. Move to another directory where you want to clone Tasmota repo 
`git clone https://github.com/arendst/Tasmota.git`

4. From the same directory run to compile the desired build   
`docker run -ti --rm -v $(pwd)/Tasmota:/tasmota -u $UID:$GID docker-tasmota -e tasmota-PT`

> `-e <buildname>` where <buildname> can be any of the [builds listed in platformio.ini](https://github.com/arendst/Tasmota/blob/063611314777d4dd9dc8c25905f19f8b25f510aa/platformio.ini#L18). If you don't define a build then ***every*** build will get compiled.

5. When compiling finishes you should have the compiled binary in `Tasmota/.pioenvs/tasmota-PT/firmware.bin` which can be flashed on your devices.

## Defining custom user_config options from commands line

**Prefix** any parameter available in `Tasmota/tasmota/my_user_config.h` with `TASMOTA_` as a environment variable for the container. 

as an example, to change:    
`#define FRIENDLY_NAME            "Tasmota" // FriendlyName`    

straight from the docker run command you need to add this anywhere after docker-tasmota:
`-e TASMOTA_FRIENDLY_NAME='"TasmotaDocker"'`

**Never forget to escape** what needs to be escaped according to your shell ([Escaping in bash](https://linuxhint.com/bash_escape_quotes/)).    

**Strings need to be in double quotes.** 

Using this option will make a backup of the existing `user_config_override.h` into `user_config_override.h.old`.

Config example:
```docker
docker run -ti --rm \
-v $(pwd)/Tasmota:/tasmota \
-e TASMOTA_STA_SSID1='"my-wifi-ap"' \
-e TASMOTA_STA_PASS1='"my-wifi-password"' \
-e TASMOTA_MQTT_HOST='"my-mqtt-ip"' \
-e TASMOTA_MQTT_USER='"my-mqtt-user"' \
-e TASMOTA_MQTT_PASS='"my-mqtt-password"' \
-e TASMOTA_WEB_PASSWORD='"my-web-password"' \
-u $UID:$GID docker-tasmota \
--environment tasmota-sensors
```
In this example we change the default WiFi AP1 name and password; MQTT host IP, username and password; web UI password into custom values and at the end we chose to build **only** tasmota-sensors binary.


## Build a specific version of Tasmota
Git clione the needed version into separate directory before using the build instructions above:   
`git clone https://github.com/arendst/Tasmota.git`   
`git -C Tasmota checkout v6.7.1`

Build it and run:
```docker
docker run -ti --rm \
-v $(pwd)/Tasmota:/tasmota \
-u $UID:$GID docker-tasmota
```

