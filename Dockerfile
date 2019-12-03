FROM python:3

LABEL description="Docker Container with a complete build environment for Tasmota using PlatformIO"
LABEL version="7.1.1"
LABEL maintainer="https://github.com/tasmota"


# Install platformio. 
RUN pip install --upgrade pip &&\ 
    pip install -U platformio

# Init project
COPY init_pio_tasmota /init_pio_tasmota

# Install project dependencies using a init project.
RUN cd /init_pio_tasmota &&\ 
    pio run &&\
    cd ../ &&\ 
    rm -fr init_pio_tasmota &&\ 
    cp -r /root/.platformio / &&\ 
    chmod -R 777 /.platformio

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/bin/bash", "/entrypoint.sh"]

