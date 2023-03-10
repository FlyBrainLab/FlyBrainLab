#!/bin/bash

set -e

python -m pip install git+https://github.com/mkturkcan/autobahn-sync.git \
                      git+https://github.com/FlyBrainLab/Neuroballad.git \
                      nxt_gem==2.0.1 \
                      git+https://github.com/mkturkcan/nxcontrol.git \
                      flybrainlab\[full\] \
                      neuromynerva
