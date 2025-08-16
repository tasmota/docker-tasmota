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

# Install system dependencies
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

# Install Python dependencies system-wide using uv
RUN uv pip install --upgrade \
    click setuptools wheel virtualenv pyserial \
    cryptography pyparsing pyelftools esp-idf-size

# Download and install custom PlatformIO version
RUN cd /tmp && \
    wget https://github.com/Jason2866/platformio-core/archive/refs/tags/v6.1.18.zip && \
    unzip v6.1.18.zip && \
    cd platformio-core-6.1.18 && \
    uv pip install .

# Create base directories with proper permissions
RUN mkdir -p /.platformio /.cache /.local /tmp \
    && chmod -R 777 /.platformio /.cache /.local /tmp \
                    /usr/local/lib /usr/local/bin

# Pre-create and configure penv with uv support
RUN mkdir -p /.platformio/penv && \
    uv venv /.platformio/penv && \
    # Ensure pip is present in the venv (uv venv may not include pip by default)
    /.platformio/penv/bin/python -m ensurepip --upgrade && \
    # Upgrade pip and also install uv into the virtual environment
    /.platformio/penv/bin/pip install --upgrade pip uv && \
    # Install basic Python dependencies required for PlatformIO and ESP-IDF operation
    /.platformio/penv/bin/pip install \
        click setuptools wheel virtualenv pyserial \
        cryptography pyparsing pyelftools && \
    # Set full permissions so uv can install packages at runtime as needed
    chmod -R 777 /.platformio/penv /.cache

# Set environment variables for penv uv usage
ENV PATH="/.platformio/penv/bin:$PATH"
ENV UV_PYTHON="/.platformio/penv/bin/python"

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
