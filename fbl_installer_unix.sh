#!/bin/bash

set -e

# The 'conda activate' command doesn't work within
# shell scripts unless we run this magic line first.
# https://github.com/conda/conda/issues/7980#issuecomment-492784093
eval "$(conda shell.bash hook)"

ENV_NAME=${1:-flybrainlab}
echo "Installing FlyBrainLab to environment '${ENV_NAME}'"

conda create -n ${ENV_NAME} python=3.7 mamba -c conda-forge -y
conda activate ${ENV_NAME}

conda_pkgs=(
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

echo ""
echo "*********************"
echo "Installation complete"
echo "*********************"
echo ""
echo "Launch FlyBrainLab with the following commands:"
echo ""
echo "    conda activate ${ENV_NAME}"
echo "    jupyter lab"
echo ""
