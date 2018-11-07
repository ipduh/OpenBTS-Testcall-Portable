#!/bin/bash
# g0 2018,
# Install USRP images,

wget http://files.ettus.com/binaries/images/uhd-images_003.009.002-release.zip

mkdir -p /usr/share/uhd
unzip ./uhd-images_003.009.002-release.zip
cp -r uhd-images_003.009.002-release/share/uhd/images /usr/share/uhd/

# test
uhd_usrp_probe
