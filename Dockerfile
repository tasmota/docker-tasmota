FROM python:3.12-slim

LABEL description="Docker Container with a complete build environment for Tasmota using PlatformIO" \
      version="15.0" \
      maintainer="blakadder_" \
      organization="https://github.com/tasmota"

# Install uv package manager
RUN pip install uv

# Environment variables for uv
ENV UV_SYSTEM_PYTHON=1
ENV UV_NO_CACHE=1

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git wget curl flex bison gperf cmake ninja-build ccache \
    libffi-dev libssl-dev dfu-util libusb-1.0-0 \
    python3-dev python3-venv build-essential \
    gcc g++ make pkg-config \
    && rm -rf /var/lib/apt/lists/*

# Install PlatformIO and dependencies globally
RUN uv pip install \
    click setuptools wheel virtualenv pyserial \
    cryptography pyparsing pyelftools esp-idf-size \
    https://github.com/Jason2866/platformio-core/archive/refs/tags/v6.1.18.zip


COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/bin/bash", "/entrypoint.sh"]
