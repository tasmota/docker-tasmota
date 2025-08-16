FROM python:latest

LABEL description="Docker Container with a complete build environment for Tasmota using PlatformIO" \
      version="14.0" \
      maintainer="blakadder_" \
      organization="https://github.com/tasmota"

# Install uv package manager
RUN pip install --upgrade pip uv

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

# Create all working directories and set permissions in a single layer
RUN mkdir -p /.platformio /.platformio/penv /.platformio/.cache/downloads /.platformio/.cache/content \
             /.platformio/.cache/http /.platformio/.cache/tmp /.platformio/dist /.platformio/packages \
             /.platformio/platforms /.platformio/tools /.cache/uv /.local /tmp /usr/local/lib /usr/local/bin && \
    chmod -R 777 /.platformio /.platformio/penv /.cache /.local /tmp /usr/local/lib /usr/local/bin

# Install basic Python dependencies system-wide using uv
RUN uv pip install --upgrade \
    click setuptools wheel virtualenv pyserial \
    cryptography pyparsing pyelftools esp-idf-size

# Download and install Tasmota pio core version
RUN cd /tmp && \
    wget https://github.com/Jason2866/platformio-core/archive/refs/tags/v6.1.18.zip && \
    unzip v6.1.18.zip && \
    cd platformio-core-6.1.18 && \
    uv pip install .

# Pre-create and configure penv using uv
RUN uv venv /.platformio/penv && \
    /.platformio/penv/bin/python -m ensurepip --upgrade && \
    /.platformio/penv/bin/python -m pip install --upgrade pip uv && \
    /.platformio/penv/bin/uv pip install \
        click setuptools wheel virtualenv pyserial \
        cryptography pyparsing pyelftools

# Set environment variables for penv uv usage
ENV PATH="/.platformio/penv/bin:$PATH"
ENV UV_PYTHON="/.platformio/penv/bin/python"

#COPY init_pio_tasmota /init_pio_tasmota

## Build project and copy platformio cache
#RUN cd /init_pio_tasmota && \
#    pio run && \
#    cd ../ && \
#    rm -fr init_pio_tasmota && \
#    cp -r /root/.platformio /

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/bin/bash", "/entrypoint.sh"]
