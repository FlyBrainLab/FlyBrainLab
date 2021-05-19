#!/bin/bash

set -e

python -m pip install git+https://github.com/mkturkcan/autobahn-sync.git \
                      git+https://github.com/FlyBrainLab/Neuroballad.git \
                      git+https://github.com/palash1992/GEM.git \
                      git+https://github.com/mkturkcan/nxcontrol \
                      flybrainlab\[full\] \
                      neuromynerva
