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

# Install system dependencies with software-properties-common
RUN apt-get update && apt-get install -y \
    git wget flex bison gperf cmake ninja-build ccache \
    libffi-dev libssl-dev dfu-util libusb-1.0-0 \
    python3-dev python3-venv software-properties-common \
    && rm -rf /var/lib/apt/lists/*

# Add Ubuntu Toolchain PPA and update libstdc++
RUN add-apt-repository ppa:ubuntu-toolchain-r/test && \
    apt-get update && \
    apt-get install -y --only-upgrade libstdc++6 && \
    rm -rf /var/lib/apt/lists/*

# Install Python dependencies system-wide
RUN uv pip install --upgrade \
    click setuptools wheel virtualenv pyserial \
    cryptography pyparsing pyelftools esp-idf-size \
    platformio

# Create base directories with proper permissions
RUN mkdir -p /.platformio /.cache /.local /tmp \
    && chmod -R 777 /.platformio /.cache /.local /tmp \
                    /usr/local/lib /usr/local/bin

# Pre-create and configure penv for ESP-IDF tools
RUN mkdir -p /.platformio/penv && \
    python3 -m venv /.platformio/penv && \
    /.platformio/penv/bin/pip install --upgrade pip && \
    /.platformio/penv/bin/pip install \
        click setuptools wheel virtualenv pyserial \
        cryptography pyparsing pyelftools && \
    chmod -R 777 /.platformio/penv

# Copy project
COPY init_pio_tasmota /init_pio_tasmota

# Install project dependencies
RUN cd /init_pio_tasmota && \
    platformio upgrade && \
    pio pkg update && \
    pio run && \
    cd ../ && \
    rm -fr init_pio_tasmota && \
    cp -r /root/.platformio / && \
    chmod -R 777 /.platformio /.cache /.local

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/bin/bash", "/entrypoint.sh"]
