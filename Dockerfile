FROM python:3.13-slim

LABEL description="Docker Container with a build environment for Tasmota using PlatformIO" \
      version="15.0" \
      maintainer="blakadder_" \
      organization="https://github.com/tasmota"

# Copy uv binary from official image  
COPY --from=ghcr.io/astral-sh/uv:latest /uv /bin/uv

# Environment variables for uv
ENV UV_SYSTEM_PYTHON=1
ENV UV_NO_CACHE=1

# Set GITHUB_ACTIONS to bypass internet connectivity check in penv_setup.py
ENV GITHUB_ACTIONS=true

# Install needed git package
RUN apt-get update && apt-get install -y --no-install-recommends git && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Install pio core
RUN uv pip install https://github.com/Jason2866/platformio-core/archive/refs/tags/v6.1.18.zip

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/bin/bash", "/entrypoint.sh"]
