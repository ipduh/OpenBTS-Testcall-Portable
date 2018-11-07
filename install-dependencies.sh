#!/bin/bash
#g0, 2018
apt-get install $(cat ./dependencies |tr '\n' ' ')
