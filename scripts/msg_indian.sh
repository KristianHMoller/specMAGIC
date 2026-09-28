#!/usr/bin/env bash
set -euo pipefail

## Project root
ROOT="$PWD"
REBUILD="${REBUILD:-1}"      # set to 0 to skip cmake rebuild
HI_PRECISION=ON
CHANNEL="VIS006"
#ALBEDO="${ALBEDO:-LANDMAP}"
ALBEDO="${ALBEDO:-MODIS}"
VERBOSE=1
EXTENT="0.0 60.0 40.0 95.0 1.0"
FIGS_DIR="${ROOT}/figs"
OUTPATH="${ROOT}/out"

export SATELLITE=msg_indian 
## Build C++ only if requested
if [[ "$REBUILD" == "1" ]]; then
    mkdir -p build
    rm -rf build/*
    cd build
    cmake -DMAGIC_HI_PRECISION=$HI_PRECISION .. > cmake_configure.log
    cmake --build . > cmake_configure.log
    cd "$ROOT"
fi

export OMP_NUM_THREADS=8
export ALBEDO=$ALBEDO
echo "Calling magic..."

## Run C++ driver
"$ROOT/build/magic" "$ROOT/" $CHANNEL 
#0


## Post-process plots
uv run python "$ROOT/py_utils/post.py" "$OUTPATH" "$FIGS_DIR" $EXTENT || { echo "Failed to post-process MTG data!!" >&2; exit 1; }

echo "Done! Thanks for now."
echo " ------------------------------------------------------------------ "
