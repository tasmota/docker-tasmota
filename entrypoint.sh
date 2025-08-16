# configure build via environment
#!/bin/bash

export UV_PYTHON="/.platformio/penv/bin/python"
export UV_CACHE_DIR="/.cache/uv"
export PATH="/.platformio/penv/bin:$PATH"

TASMOTA_VOLUME='/tasmota'

chmod -R 777 /.platformio /.cache /.local

if [ -d $TASMOTA_VOLUME ]; then
	cd $TASMOTA_VOLUME
	echo "Compiling Tasmota..."
	pio run $@
	echo "All done! Find your builds in Tasmota/build_output/firmware/"
else
	echo ">>> NO TASMOTA VOLUME MOUNTED --> EXITING"
	exit 0;
fi
