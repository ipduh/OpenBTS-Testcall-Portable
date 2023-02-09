## OpenBTS-Testcall-Portable
OpenBTS with Testcall Debian Packages for Ubuntu 16.04LTS on amd64

## Synopsis


It aims in easing the installation and configuration of a GSM/GPRS one basestation network with OpenBTS.

This is my packaged fork https://github.com/ipduh/openbts of OpenBTS.

This version of OpenBTS differs from the current version of OpenBTS in the following.

1)It backports testcall, a feature that makes it easy to send raw packets through a socket.

2)It allows for larger IMSIs.

## Install

$ sudo bash
$ whoami  <br>
root      <br>

$ ./install-dependencies.sh     <br>
$ ./install-uhd-images.sh       <br>
$ dpkg -i ./packages/*.deb      <br>
$ cp gsm_helpers.sh /OpenBTS    <br>
$ echo '. /OpenBTS/gsm_helpers.sh' >> ~/.bashrc <br>


## Copyright & Legal

Same with the original Range Networks License.
Please see LEGAL and LICENSE.

