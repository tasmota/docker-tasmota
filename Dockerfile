FROM python:3.12

LABEL description="Docker Container with a complete build environment for Tasmota using PlatformIO" \
      version="14.0" \
      maintainer="blakadder_" \
      organization="https://github.com/tasmota"

# Install uv package manager
RUN pip install pip uv

# Environment variables for uv
ENV UV_SYSTEM_PYTHON=1
ENV UV_CACHE_DIR=/.cache/uv

# Install required system dependencies
RUN apt-get update && apt-get install -y \
    git wget flex bison gperf cmake ninja-build ccache \
    libffi-dev libssl-dev dfu-util libusb-1.0-0 \
    python3-dev python3-venv build-essential unzip \
    && rm -rf /var/lib/apt/lists/*

# Install GCC 13 from Debian testing to support GLIBCXX_3.4.32 (required for mklittlefs)
RUN echo "deb http://deb.debian.org/debian testing main" > /etc/apt/sources.list.d/testing.list && \
    echo "Package: *" > /etc/apt/preferences.d/testing && \
    echo "Pin: release a=testing" >> /etc/apt/preferences.d/testing && \
    echo "Pin-Priority: 50" >> /etc/apt/preferences.d/testing && \
    apt-get update && \
    apt-get install -y -t testing gcc-13 g++-13 libstdc++6 && \
    rm /etc/apt/sources.list.d/testing.list && \
    rm /etc/apt/preferences.d/testing && \
    rm -rf /var/lib/apt/lists/*

# Create directories and set permissions - include ESP-IDF directories
RUN mkdir -p /.platformio /.cache/uv /.local /tmp /usr/local/lib /usr/local/bin /.espressif && \
    chmod -R 777 /.platformio /.cache/uv /.local /tmp /usr/local/lib /usr/local/bin /.cache /.espressif

# Install PlatformIO and dependencies globally to avoid ESP-IDF venv conflicts
RUN uv pip install --system \
    click setuptools wheel virtualenv pyserial \
    cryptography pyparsing pyelftools esp-idf-size \
    https://github.com/Jason2866/platformio-core/archive/refs/tags/v6.1.18.zip

COPY init_pio_tasmota /init_pio_tasmota

# Build project and copy platformio cache
RUN cd /init_pio_tasmota && \
    pio run && \
    cd ../ && \
    rm -fr init_pio_tasmota && \
    cp -r /root/.platformio / && \
    rm -f /.platformio/*.lock && \
    chmod -R 777 /.platformio

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/bin/bash", "/entrypoint.sh"]
