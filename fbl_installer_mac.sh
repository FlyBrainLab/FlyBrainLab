#!/bin/bash

set -e

eval "$(conda shell.bash hook)"
conda create -n flybrainlab mamba -c conda-forge -y
conda activate flybrainlab

conda_pkgs=(
    'python=3.7'
    nodejs
    scipy
    pandas
    cookiecutter
    git
    yarn
    txaio
    twisted
    autobahn
    crochet
    service_identity
    matplotlib
    h5py
    seaborn
    fastcluster
    networkx
    msgpack-python
    msgpack-numpy
    jupyter
    'jupyterlab>=2.2.8'
)

mamba install ${conda_pkgs[@]} -c conda-forge -y
pip install autobahn-sync
jupyter labextension install @flybrainlab/neuromynerva

mkdir FlyBrainLab
cd FlyBrainLab

git clone https://github.com/FlyBrainLab/Neuroballad.git
git clone https://github.com/FlyBrainLab/FBLClient.git

cd ./Neuroballad
python setup.py develop

cd ../FBLClient
python setup.py develop
