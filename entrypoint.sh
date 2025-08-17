# configure build via environment
#!/bin/bash

# Set umask so new files/directories get full permissions automatically
umask 000

# Run permission fix script
/fix_permissions.sh

# Set UV environment variables to avoid cache issues
export UV_CACHE_DIR="/.cache/uv"
export UV_NO_CACHE=1

TASMOTA_VOLUME='/tasmota'

if [ -d $TASMOTA_VOLUME ]; then
    cd $TASMOTA_VOLUME
    echo "Compiling Tasmota..."
    pio run $@
    echo "All done! Find your builds in Tasmota/build_output/firmware/"
else
    echo ">>> NO TASMOTA VOLUME MOUNTED --> EXITING"
    exit 0;
fi
