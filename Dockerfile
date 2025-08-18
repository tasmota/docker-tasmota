FROM python:latest

LABEL description="Docker Container with a complete build environment for Tasmota using PlatformIO" \
      version="14.0" \
      maintainer="blakadder_" \
      organization="https://github.com/tasmota"

# Install uv package manager
RUN pip install uv

# Environment variables for uv
ENV UV_SYSTEM_PYTHON=1
ENV UV_NO_CACHE=1

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git wget flex bison gperf cmake ninja-build ccache \
    libffi-dev libssl-dev dfu-util libusb-1.0-0 \
    python3-dev python3-venv build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install GCC 13 from Debian testing
RUN echo "deb http://deb.debian.org/debian testing main" > /etc/apt/sources.list.d/testing.list && \
    echo "Package: *" > /etc/apt/preferences.d/testing && \
    echo "Pin: release a=testing" >> /etc/apt/preferences.d/testing && \
    echo "Pin-Priority: 50" >> /etc/apt/preferences.d/testing && \
    apt-get update && \
    apt-get install -y -t testing gcc-13 g++-13 libstdc++6 && \
    rm /etc/apt/sources.list.d/testing.list && \
    rm /etc/apt/preferences.d/testing && \
    rm -rf /var/lib/apt/lists/*

# Install Python dependencies system-wide with uv
RUN uv pip install \
    click setuptools wheel virtualenv pyserial \
    cryptography pyparsing pyelftools esp-idf-size \
    https://github.com/Jason2866/platformio-core/archive/refs/tags/v6.1.18.zip

# Create base directories with proper permissions
RUN mkdir -p /.platformio /.platformio/penv /.cache /.local /tmp \
    && chmod -R 777 /.platformio /.platformio/penv /.cache /.local /tmp \
                    /usr/local/lib /usr/local/bin

# Pre-create and configure penv with pip not with uv to avoid permission issues 
RUN python3 -m venv /.platformio/penv && \
    /.platformio/penv/bin/pip install \
        setuptools wheel virtualenv

# Copy project
COPY init_pio_tasmota /init_pio_tasmota

# Install project dependencies
RUN cd /init_pio_tasmota && \
    pio run && \
    cd ../ && \
    rm -fr init_pio_tasmota && \
    rm -f /root/.platformio/*.lock && \
    cp -r /root/.platformio / && \
    rm -f /.platformio/*.lock && \
    chmod -R 777 /.platformio /.platformio/penv /.cache /.local /tmp \
                    /usr/local/lib /usr/local/bin

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/bin/bash", "/entrypoint.sh"]
