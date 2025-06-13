FROM python:latest

LABEL description="Docker Container with a complete build environment for Tasmota using PlatformIO" \
      version="13.0" \
      maintainer="blakadder_" \
      organization="https://github.com/tasmota"       

# Disable pip root user warning
ENV PIP_ROOT_USER_ACTION=ignore

# Install platformio
RUN pip install --upgrade pip &&\ 
    pip install --upgrade platformio

# global pip configuration
RUN mkdir -p /etc/pip && \
    echo "[global]" > /etc/pip/pip.conf && \
    echo "root-user-action = ignore" >> /etc/pip/pip.conf && \
    echo "no-warn-script-location = true" >> /etc/pip/pip.conf

# Init project
COPY init_pio_tasmota /init_pio_tasmota

# Install project dependencies using a init project.
RUN cd /init_pio_tasmota &&\ 
    platformio upgrade &&\
    pio pkg update &&\
    pio run &&\
    cd ../ &&\ 
    rm -fr init_pio_tasmota &&\ 
    cp -r /root/.platformio / &&\ 
    mkdir /.cache /.local &&\
    chmod -R 777 /.platformio /usr/local/lib /usr/local/bin /.cache /.local &&\ 
    chmod -R 777 /usr/local/lib/python*/site-packages/

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/bin/bash", "/entrypoint.sh"]
