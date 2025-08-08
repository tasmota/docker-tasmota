FROM python:latest

LABEL description="Docker Container with a complete build environment for Tasmota using PlatformIO" \
      version="14.0" \
      maintainer="blakadder_" \
      organization="https://github.com/tasmota"

# Install uv package manager
RUN pip install --upgrade pip uv

# Configure uv environment variables
ENV UV_SYSTEM_PYTHON=1
ENV UV_CACHE_DIR=/.cache/uv

# Install system dependencies required by ESP-IDF tools
RUN apt-get update && apt-get install -y \
    git wget flex bison gperf cmake ninja-build ccache \
    libffi-dev libssl-dev dfu-util libusb-1.0-0 \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies required by idf_tools.py
RUN uv pip install --upgrade \
    click \
    setuptools \
    wheel \
    virtualenv \
    pyserial \
    platformio

# Create all necessary directories with full permissions
RUN mkdir -p /.platformio \
             /.cache \
             /penv \
             /.local \
             /tmp \
             /root/.platformio \
    && chmod -R 777 /.platformio \
                    /.cache \
                    /penv \
                    /.local \
                    /tmp \
                    /root \
                    /usr/local/lib \
                    /usr/local/bin

# Additional permissions after PlatformIO installation
RUN chmod -R 777 /usr/local/lib/python*/site-packages/

# Init project
COPY init_pio_tasmota /init_pio_tasmota

# Install project dependencies with verbose output for debugging
RUN cd /init_pio_tasmota &&\ 
    platformio upgrade &&\
    pio pkg update &&\
    pio run --verbose &&\
    cd ../ &&\ 
    rm -fr init_pio_tasmota &&\ 
    cp -r /root/.platformio / &&\ 
    chmod -R 777 /.platformio /.cache /.local &&\ 
    chmod -R 777 /usr/local/lib/python*/site-packages/

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/bin/bash", "/entrypoint.sh"]
