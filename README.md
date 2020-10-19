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

# Setting up FlyBrainLab

## Prerequisites

### macOS

Before the installation, enter the following to your terminal:
```bash
xcode-select --install
```
to install the Xcode Command Line Tools that are needed for the compilation of certain packages.

If you encounter error:
```
Can’t install the software because it is not currently available from the Software Update server.
```
you can download the installer directly at https://developer.apple.com/download/more/ (Apple ID Login required), and select the latest stable version. If you encounter further error, you can try installing Xcode and then the Command Line Tools again.

## Installation

### Quick Installation

#### Linux/macOS

First, make sure that you have an installation of Anaconda or miniconda. Anaconda can be installed from https://www.anaconda.com/ and miniconda is available at https://docs.conda.io/en/latest/miniconda.html. We recommend Anaconda. Secondly, download fbl_installer.sh from this repository (link above). Then, open up your terminal or command line, go to an empty directory in which you want your FlyBrainLab installation to reside and enter the following line by line:

```bash
conda create -n flybrainlab python=3.7 -y
source activate flybrainlab
```

You can change "flybrainlab" to a different name of your choice. Then, on macOS, run:

```bash
sh fbl_installer_mac.sh
```

on Linux, run:

```bash
sh fbl_installer_ubuntu.sh
```

Linux installation was only tested on Ubuntu, but should work with the other Linux distributions.

#### Windows

First, make sure that you have an installation of Anaconda or miniconda. Anaconda can be installed from https://www.anaconda.com/ and miniconda is available at https://docs.conda.io/en/latest/miniconda.html. We recommend Anaconda. Secondly, download fbl_installer.cmd from this repository (link above). Then, open up your terminal or command line, go to an empty directory in which you want your FlyBrainLab installation to reside and run the following:

```bash
fbl_installer.cmd
```

### Step-by-step Installation

First, make sure that you have an installation of Anaconda or miniconda. Anaconda can be installed from https://www.anaconda.com/ and miniconda is available at https://docs.conda.io/en/latest/miniconda.html. We recommend Anaconda. Then, open up your terminal or command line, go to an empty directory in which you want your FlyBrainLab installation to reside and enter the following line by line:
```bash
# create anaconda environment called flybrainlab with appropriate packages installed
conda create -n flybrainlab python=3.7 nodejs scipy pandas jupyterlab cookiecutter git yarn -c conda-forge -y
# activate the flybrainlab environment just created
# if you have conda<4.4, you may need to use `source activate flybrainlab` instead
conda activate flybrainlab
# Install additional package into the environment
pip install jupyter jupyterlab==2.1.5
pip install txaio twisted autobahn crochet service_identity autobahn-sync matplotlib h5py seaborn fastcluster networkx msgpack
# If on Windows, execute the following:
pip install pypiwin32

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
jlpm
jlpm run build

# Execute this if you are a user
jupyter labextension install .
jupyter lab build
jupyter lab

# Execute this if you are a developer
jupyter labextension link .
jupyter lab --watch
```
You may be prompted. On Windows, you will only need to write "activate neuromynerva" instead of "source activate neuromynerva". 

# Starting Up FlyBrainLab

After the installation, simply run
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
