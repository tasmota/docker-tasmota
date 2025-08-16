# configure build via environment
#!/bin/bash

# Configure build environment to use penv virtual environment
export UV_PYTHON="/.platformio/penv/bin/python"
export UV_CACHE_DIR="/.cache/uv"
export PATH="/.platformio/penv/bin:$PATH"
export PYTHON="/.platformio/penv/bin/python"
export PYTHONPATH="/.platformio/penv/lib/python3.13/site-packages:$PYTHONPATH"

TASMOTA_VOLUME='/tasmota'

chmod -R 777 /.platformio /.cache /.local

if [ -d $TASMOTA_VOLUME ]; then
    cd $TASMOTA_VOLUME
    echo "Compiling Tasmota..."
    echo "Using Python: $(which python)"
    echo "Using PlatformIO: $(which pio)"
    pio run $@
    echo "All done! Find your builds in Tasmota/build_output/firmware/"
else
    echo ">>> NO TASMOTA VOLUME MOUNTED --> EXITING"
    exit 0;
fi
