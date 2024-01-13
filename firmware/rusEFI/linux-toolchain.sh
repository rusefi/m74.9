#!/bin/bash

# see https://rusefi.com/forum/viewtopic.php?f=5&t=2636

set -e

sudo apt-get install automake libtool autotools-dev libusb-1.0-0-dev libhidapi-dev libjaylink-dev

git clone https://github.com/dron0gus/openocd openocd.dron0gus
cd openocd.dron0gus
git checkout artery-dev
git submodule update --init --recursive
./bootstrap
./configure --enable-jlink --enable-cmsis-dap --enable-stlink
make -j
sudo make install
