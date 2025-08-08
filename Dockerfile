FROM python:latest

LABEL description="Docker Container with a complete build environment for Tasmota using PlatformIO" \
      version="13.0" \
      maintainer="blakadder_" \
      organization="https://github.com/tasmota"       

# Install uv package manager
RUN pip install --upgrade pip uv

# Configure uv environment variables
ENV UV_SYSTEM_PYTHON=1
ENV UV_CACHE_DIR=/.cache/uv

# Install platformio using uv
RUN uv pip install --upgrade platformio

# Create uv cache directory and set permissions
RUN mkdir -p /.cache/uv /.local &&\
    chmod -R 777 /.cache /.local

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
    chmod -R 777 /.platformio /usr/local/lib /usr/local/bin /.cache /.local &&\ 
    chmod -R 777 /usr/local/lib/python*/site-packages/

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/bin/bash", "/entrypoint.sh"]
