# configure build via environment
#!/bin/bash

# Set umask so new files/directories get full permissions automatically
umask 000

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
