#!/bin/bash

set -e

python -m pip install git+https://github.com/mkturkcan/autobahn-sync.git \
                      git+https://github.com/FlyBrainLab/Neuroballad.git \
                      git+https://github.com/jernsting/nxt_gem.git \
                      git+https://github.com/mkturkcan/nxcontrol.git \
                      flybrainlab\[full\] \
                      neuromynerva
