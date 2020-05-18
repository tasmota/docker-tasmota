# configure build via environment
#!/bin/bash

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
