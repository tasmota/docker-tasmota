#!/bin/bash

# Set umask for new files
umask 000

TASMOTA_VOLUME='/tasmota'

if [ -d $TASMOTA_VOLUME ]; then
    cd $TASMOTA_VOLUME
    echo "Compiling Tasmota..."
    
    # Run compilation
    pio run $@
    
    # Fix ownership of build output files to match the host user
    if [ -n "$HOST_UID" ] && [ -n "$HOST_GID" ]; then
        chown -R $HOST_UID:$HOST_GID build_output/ 2>/dev/null || true
    fi

    echo "All done! Find your builds in Tasmota/build_output/firmware/"
else
    echo ">>> NO TASMOTA VOLUME MOUNTED --> EXITING"
    exit 0;
fi
