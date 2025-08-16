# configure build via environment
#!/bin/bash

# Set umask so new files/directories get full permissions automatically
umask 000

# Configure build environment to use penv virtual environment  
export UV_PYTHON="/.platformio/penv/bin/python"
export UV_CACHE_DIR="/.cache/uv"
export PATH="/.platformio/penv/bin:$PATH"
export PYTHON="/.platformio/penv/bin/python"

# Pre-create ESP-IDF venv directories that might be needed
mkdir -p /.platformio/penv/.espidf-{5.3.3,5.3.4,5.4.2,5.4.3,5.5.0,5.5.1} 2>/dev/null || true

TASMOTA_VOLUME='/tasmota'

if [ -d $TASMOTA_VOLUME ]; then
    cd $TASMOTA_VOLUME
    echo "Compiling Tasmota..."
#    echo "Using Python: $(which python)"
#    echo "Using PlatformIO: $(which pio)"
    pio run $@
    echo "All done! Find your builds in Tasmota/build_output/firmware/"
else
    echo ">>> NO TASMOTA VOLUME MOUNTED --> EXITING"
    exit 0;
fi
