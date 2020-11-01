#/bin/bash

# STEP 1: Make sure the system prerequisites are installed.

# The following block of code install prerequisites.
# They are left out so the installation script does not need privilege.
# Make sure you have the folloiwng packages installed,
# otherwise please ask a system administrator to install them

#echo "Installing prerequisites"
#sudo apt update
#sudo apt install -y wget default-jre curl build-essential tar apt-transport-https tmux

# End of system prerequisties.

set -e


# STEP 2: folder configuration.
# List cuda directory.
# Choose the conda environments name and where you want to put the ffbo repositories.
# Choose where you want to install OrientDB
# Choose the port for the FFBO processor. Make sure it is not used by other processes.

# existing directories
CUDA_ROOT=/usr/local/cuda # root directory where you installed cuda

# To be installed
FFBO_ENV=ffbo # conda environment for main fbl
NLP_ENV=ffbo_legacy # additional conda environment for NLP
FFBO_DIR=$HOME/ffbo # directory to store local repositories
ORIENTDB_ROOT=$HOME/orientdb # root directory where you want to install OrientDB
FFBO_PORT=8081

# End of folder configuration.

# check if CUDA exists
if ! command -v $CUDA_ROOT/bin/nvcc &> /dev/null
then
    echo "CUDA installation cannot be found. Please make sure to use the correct CUDA directory. If you don't have CUDA installed, go to https://developer.nvidia.com/cuda-downloads"
    exit
fi

# check if directories already exist
if [ -d "$REPO_DIR" ]; then
    echo "$REPO_DIR already exists, please remove before continue"
    exit 1
fi

if [ -d "$ORIENTDB_ROOT" ]; then
    echo "$ORIENTDB_ROOT already exists, please remove it or use another directory"
    exit 1
fi

# check conda
if ! command -v conda &> /dev/null
then
    echo "conda not found. Please install miniconda/andaconda, or make sure conda command is in your PATH"
    exit 1
fi

CONDA_ROOT=$(conda info --base)  # where you installed conda (miniconda/anaconda)

if [ -d "$CONDA_ROOT/envs/$FFBO_ENV" ]; then
    echo "conda environment $FFBO_ENV already exists, please remove or use a different name"
    exit 1
fi

if [ -d "$CONDA_ROOT/envs/$NLP_ENV" ]; then
    echo "conda environment $NLP_ENV already exists, please remove or use a different name"
    exit 1
fi


#install orientdb
echo "Installing OrientDB ......"
wget https://s3.us-east-2.amazonaws.com/orientdb3/releases/3.0.30/orientdb-3.0.30.tar.gz
tar zxf orientdb-3.0.30.tar.gz --directory .
mv orientdb-3.0.30 $ORIENTDB_ROOT
rm orientdb-3.0.30.tar.gz
sed -i '/<\/users>/i \
      <user resources="*" password="{PBKDF2WithHmacSHA256}CB55FC353E97910517F5E8811FC48BB89B7CDF9B66BF880C:A3664992731721A52998BEE95C1CA73BAA6093E91191FA1C:65536" name="root"/> \
      <user resources="connect,server.listDatabases,server.dblist" password="{PBKDF2WithHmacSHA256}289DE306D44BAAD7676BA04426F19A056B4CF8904BB80A71:001BFE74763F762037E7676752BF9D37F3A508A331BEB41C:65536" name="guest"/>' $ORIENTDB_ROOT/config/orientdb-server-config.xml

# Set orientdb root password to root
echo "ORIENTDB_ROOT_PASSWORD=root" | tee -a ~/.bashrc
# Set orientdb memory limits, minimum set to 1GB, maximum set to 32GB.
# Change if you have less memory
echo 'ORIENTDB_OPTS_MEMORY="-Xms1G -Xmx32G"' | tee -a ~/.bashrc

# download packages
echo "Downloading packages"
mkdir $FFBO_DIR
cd $FFBO_DIR
git clone https://github.com/fruitflybrain/ffbo.nlp_component.git
git clone https://github.com/fruitflybrain/ffbo.neuroarch_nlp.git
git clone https://github.com/fruitflybrain/quepy.git
git clone https://github.com/fruitflybrain/ffbo.processor.git
git clone https://github.com/fruitflybrain/ffbo.neuroarch_component.git
git clone https://github.com/fruitflybrain/neuroarch.git
git clone https://github.com/fruitflybrain/ffbo.neurokernel_component.git
git clone https://github.com/fruitflybrain/ffbo.neuronlp.git
cd ffbo.neuronlp
git checkout hemibrain
git clone https://github.com/fruitflybrain/ffbo.lib.git lib
cd lib
git checkout hemibrain
cd ../../

git clone https://github.com/FlyBrainLab/Neuroballad.git
git clone https://github.com/FlyBrainLab/FBLClient.git
git clone https://github.com/FlyBrainLab/Tutorials.git
git clone https://github.com/FlyBrainLab/run_scripts.git
git clone https://github.com/neurokernel/neurokernel.git
git clone https://github.com/neurokernel/neurodriver.git
git clone https://github.com/neurokernel/retina.git
mkdir nk_tmp

. $CONDA_ROOT/etc/profile.d/conda.sh

echo "Installing FBL ......"
conda create -n $FFBO_ENV python=3.6 nodejs scipy pandas cookiecutter git yarn jupyterlab=2.1.5 -c conda-forge -y


# Install OpenMPI if cannot find a CUDA-aware openmpi installation
if ((command -v ompi_info &> /dev/null) && (ompi_info -a | grep "xtensions" | grep -q "cuda"))
then
    echo "Found OpenMPI with CUDA support, skipping OpenMPI installation."
else
    echo "Installing OpenMPI ......"
    wget https://download.open-mpi.org/release/open-mpi/v4.0/openmpi-4.0.3.tar.gz
    tar xzf openmpi-4.0.3.tar.gz
    rm -rf openmpi-4.0.3.tar.gz
    cd openmpi-4.0.3
    ./configure --with-cuda=$CUDA_ROOT --disable-mpi-fortran --enable-shared --prefix=$CONDA_ROOT/envs/$FFBO_ENV
    make -j8
    make install
    cd ../
    rm -rf openmpi-4.0.3
    echo "OpenMPI installed"
fi

echo "Installing FFBO environments"
conda activate $FFBO_ENV
pip install autobahn[twisted]==19.2.1 beautifulsoup4 tinydb simplejson configparser docopt sparqlwrapper python-levenshtein pyopenssl service_identity plac==0.9.6 crossbar==17.12.1 datadiff refo msgpack msgpack-numpy pyorient_native pyorient daff path.py txaio crochet autobahn-sync seaborn fastcluster networkx h5py jupyter matplotlib pycuda mpi4py

sed -i.bak -e '100,103d' $CONDA_ROOT/envs/$FFBO_ENV/lib/python3.6/site-packages/pyorient/orient.py
sed -i.bak -e '222d' $CONDA_ROOT/envs/$FFBO_ENV/lib/python3.6/site-packages/jupyterlab_server/process.py

cd $FFBO_DIR/ffbo.processor
python setup.py develop
cd $FFBO_DIR/ffbo.neuroarch_component
python setup.py develop
cd $FFBO_DIR/neuroarch
python setup.py develop
cd $FFBO_DIR/neurokernel
git checkout managerless
python setup.py develop
cd $FFBO_DIR/neurodriver
git checkout fbl
python setup.py develop
cd $FFBO_DIR/retina
python setup.py develop
cd $FFBO_DIR/Neuroballad
python setup.py develop
cd $FFBO_DIR/FBLClient
python setup.py develop

jupyter labextension install @flybrainlab/neuromynerva

wget https://cdn.jsdelivr.net/gh/flybrainlab/NeuroMynerva@master/schema/plugin.json.local -O $CONDA_ROOT/envs/$FFBO_ENV/share/jupyter/lab/staging/node_modules/\@flybrainlab/neuromynerva/schema/plugin.json
sed -i -e "s+8081+$FFBO_PORT+g" $CONDA_ROOT/envs/$FFBO_ENV/share/jupyter/lab/staging/node_modules/\@flybrainlab/neuromynerva/schema/plugin.json
conda deactivate

conda create -n $NLP_ENV python=2.7 numpy -y
conda activate $NLP_ENV
pip install autobahn[twisted]==19.2.1 configparser docopt sparqlwrapper nltk spacy==1.6.0 fuzzywuzzy python-levenshtein pyopenssl plac==0.9.6 crossbar==17.12.1
cd $FFBO_DIR/ffbo.nlp_component
python setup.py develop
cd $FFBO_DIR/ffbo.neuroarch_nlp
python setup.py develop
cd $FFBO_DIR/quepy
git checkout apps
python setup.py develop
cd ../
wget https://github.com/explosion/spaCy/releases/download/v1.6.0/en-1.1.0.tar.gz
mkdir $CONDA_ROOT/envs/$NLP_ENV/lib/python2.7/site-packages/spacy/data
tar zxvf en-1.1.0.tar.gz --directory $CONDA_ROOT/envs/$NLP_ENV/lib/python2.7/site-packages/spacy/data
rm en-1.1.0.tar.gz
conda deactivate

mkdir -p ~/.ffbo/config
cp $FFBO_DIR/ffbo.processor/config.ini ~/.ffbo/config/config.ini
sed -i -e "11,15d; 26,29d; s+8081+$FFBO_PORT+g" ~/.ffbo/config/config.ini

cp -r $FFBO_DIR/run_scripts/flybrainlab $FFBO_DIR/bin
cd $FFBO_DIR/bin
sed -i -e "s+{FFBO_DIR}+$FFBO_DIR+g; s+{FFBO_ENV}+$FFBO_ENV+g" run_processor.sh
sed -i -e "s+{FFBO_DIR}+$FFBO_DIR+g; s+{NLP_ENV}+$NLP_ENV+g" run_nlp.sh
sed -i -e "s+{FFBO_DIR}+$FFBO_DIR+g; s+{FFBO_ENV}+$FFBO_ENV+g" run_neuroarch.sh
sed -i -e "s+{FFBO_DIR}+$FFBO_DIR+g; s+{FFBO_ENV}+$FFBO_ENV+g" run_neurokernel.sh
sed -i -e "s+{ORIENTDB_ROOT}+$ORIENTDB_ROOT+g" run_database.sh
sed -i -e "s+{FFBO_DIR}+$FFBO_DIR+g; s+{FFBO_ENV}+$FFBO_ENV+g" run_fbl.sh
sed -i -e "s+{FFBO_DIR}+$FFBO_DIR+g" start.sh
sed -i -e "s+{ORIENTDB_ROOT}+$ORIENTDB_ROOT+g" shutdown.sh
sed -i -e "s+{FFBO_DIR}+$FFBO_DIR+g" update.sh
rm -rf $FFBO_DIR/run_scripts

echo "Installation complete. Downloading databases ......"
cd $ORIENTDB_ROOT/databases
wget --load-cookies /tmp/cookies.txt "https://docs.google.com/uc?export=download&confirm=$(wget --quiet --save-cookies /tmp/cookies.txt --keep-session-cookies --no-check-certificate 'https://docs.google.com/uc?export=download&id=1Nbo0C55X52OeYJtYVzB-52mo7I7H4UCc' -O- | sed -rn 's/.*confirm=([0-9A-Za-z_]+).*/\1\n/p')&id=1Nbo0C55X52OeYJtYVzB-52mo7I7H4UCc" -O flycircuit.tar.gz && rm -rf /tmp/cookies.txt
tar
tar xf flycircuit.tar.gz
wget --load-cookies /tmp/cookies.txt "https://docs.google.com/uc?export=download&confirm=$(wget --quiet --save-cookies /tmp/cookies.txt --keep-session-cookies --no-check-certificate 'https://docs.google.com/uc?export=download&id=1puvabvKGFBchKiD56cjlu3MFNQ-Soam1' -O- | sed -rn 's/.*confirm=([0-9A-Za-z_]+).*/\1\n/p')&id=1puvabvKGFBchKiD56cjlu3MFNQ-Soam1" -O hemibrain.tar.gz && rm -rf /tmp/cookies.txt
tar xf hemibrain.tar.gz
wget --load-cookies /tmp/cookies.txt "https://docs.google.com/uc?export=download&confirm=$(wget --quiet --save-cookies /tmp/cookies.txt --keep-session-cookies --no-check-certificate 'https://docs.google.com/uc?export=download&id=1U4TfYXzhN7siQtwupDDmgW7sOBRXmQrL' -O- | sed -rn 's/.*confirm=([0-9A-Za-z_]+).*/\1\n/p')&id=1U4TfYXzhN7siQtwupDDmgW7sOBRXmQrL" -O l1em.tar.gz && rm -rf /tmp/cookies.txt
tar xf l1em.tar.gz

echo

echo "Done! This set up only allows you to run one set of frontend/backend on your system."

echo
echo "To start FlyBrainLab, run $FFBO_DIR/bin/start.sh."
echo "Closing jupyter will not terminate the backend servers. To start jupyter again, run $FFBO_DIR/bin/run_fbl.sh."
echo "To shutdown all FlyBrainLab processes, run $FFBO_DIR/bin/shutdown.sh."
