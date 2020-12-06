#!/bin/bash

set -e

conda install nodejs scipy pandas cookiecutter git yarn -c conda-forge -y
pip install jupyter "jupyterlab>=2.2.8"
pip install txaio autobahn[twisted]==19.2.1 crochet service_identity matplotlib h5py seaborn fastcluster networkx msgpack msgpack-numpy
pip install git+https://github.com/mkturkcan/autobahn-sync.git
mkdir FlyBrainLab
cd FlyBrainLab
git clone https://github.com/FlyBrainLab/Neuroballad.git
git clone https://github.com/FlyBrainLab/FBLClient.git
cd ./Neuroballad
python setup.py develop
cd ../FBLClient
python setup.py develop
jupyter labextension install @flybrainlab/neuromynerva
