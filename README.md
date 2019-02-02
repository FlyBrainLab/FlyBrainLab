<p align="center">
  <img src="https://github.com/flybrainlab/flybrainlab/raw/master/flylablogo.png" width="50%">
</p>

<p align="center">
  <a href="https://twitter.com/flybrainobs">
        <img src="https://img.shields.io/twitter/follow/flybrainobs.svg?style=social&label=Follow"
             alt="Twitter Follow">
    </a>
    <a href="https://github.com/FlyBrainLab/FlyBrainLab">
        <img src="https://img.shields.io/github/license/FlyBrainLab/FlyBrainLab.svg"
             alt="GitHub license">
    </a>
    <a href="https://github.com/FlyBrainLab/FlyBrainLab">
        <img src="https://img.shields.io/github/last-commit/FlyBrainLab/FlyBrainLab.svg"
             alt="GitHub last commit">
    </a>
</p>


FlyBrainLab provides an environment where computational researchers can present configurable, executable neural circuits, and experimental scientists can interactively explore circuit structure and function ultimately leading to biological validation.

# Installation

First, make sure that you have an installation of Anaconda or miniconda. Anaconda can be installed from https://www.anaconda.com/ and miniconda is available at https://docs.conda.io/en/latest/miniconda.html . We recommend Anaconda. Then, open up your terminal or command line, go to an empty directory in which you want your FlyBrainLab installation to reside and enter the following line by line:
```bash
# create anaconda environment called neuromynerva with appropriate packages installed
conda create -n neuromynerva python=3.6 nodejs scipy pandas jupyterlab cookiecutter git yarn -c conda-forge
# activate the neuromynerva environment just created
# if you have conda>4.4, you may need to use `conda activate neuromynerva` instead
source activate neuromynerva
# Install additional package into the environment
pip install txaio twisted autobahn crochet service_identity autobahn-sync matplotlib h5py seaborn networkx jupyter

# Create a preferred installation directory and go into that directory, For example:
# mkdir ~/MyFBL
# cd ~/MyFBL

# Clone packages into your preferred directory (~/MyFBL) in the example above
git clone https://github.com/FlyBrainLab/Neuroballad.git
git clone https://github.com/FlyBrainLab/FBLClient.git
git clone https://github.com/FlyBrainLab/NeuroMynerva.git

# Install all relevant packages
cd ./Neuroballad
python setup.py develop
cd ../FBLClient
python setup.py develop
cd ../NeuroMynerva
yarn install
npm run link
jupyter lab build
```
You may be prompted. On Windows, you will only need to write "activate neuromynerva" instead of "source activate neuromynerva". After this installation, simply run
```bash
jupyter lab
```
to get started.

To test if your installations are working, check
1. whether you see an "FFBO" section below "Other" in JupyterLab Launcher, as shown here:

<p align="center">
  <img src="https://github.com/flybrainlab/flybrainlab/raw/master/fbl_loaded.png" width="50%">
</p>

2. whether you can run the example notebook [here](https://github.com/FlyBrainLab/FBLClient/blob/master/examples/jupyter_notebooks/1_introduction.ipynb).
