## OpenBTS-Testcall-Portable
OpenBTS with Testcall Debian Packages for Ubuntu 16.04LTS on amd64

## Synopsis


It aims in easing the installation and configuration of a GSM/GPRS one basestation network with OpenBTS.

This is my packaged fork, https://github.com/ipduh/openbts, of OpenBTS,
 along with gsm_helpers, https://github.com/ipduh/gsm_helpers, a bashrc
 script with helper admin functions.

This version of OpenBTS differs from the current version of OpenBTS in the following.

1)It backports Testcall, a feature that makes it easy to send raw packets through a socket.

2)It allows for larger IMSIs.

## Install
```
$ sudo bash
# whoami
root

# ./install-dependencies.sh
# ./install-uhd-images.sh
# dpkg -i ./packages/*.deb
# cp gsm_helpers.sh /OpenBTS
# echo 'source /OpenBTS/gsm_helpers.sh' >> ~/.bashrc
# . ~/.bashrc
```

## Copyright & Legal

Same with the original Range Networks License.
Please see LEGAL and LICENSE.

