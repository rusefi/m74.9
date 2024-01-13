#!/bin/bash

# see https://rusefi.com/forum/viewtopic.php?f=5&t=2636

set -e

git clone https://github.com/dron0gus/openocd openocd.dron0gus
cd openocd.dron0gus
git checkout artery-dev
git submodule --init --recursive
./bootstrap
./configure
# make sure CMSIS-DAP is enabled
make -j
sudo make install
