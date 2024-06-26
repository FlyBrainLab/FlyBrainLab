#!/bin/bash

# STEP 1: Make sure the system prerequisites are installed.

# The following block of code install prerequisites.
# They are left out so the installation script does not need privilege.
# Make sure you have the folloiwng packages installed,
# otherwise please ask a system administrator to install them

#echo "Installing prerequisites"
#sudo apt update
#sudo apt install -y wget default-jre curl build-essential tar apt-transport-https tmux sendmail

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
BASE=$HOME # base directory where the folders will be installed
CROSSBAR_ENV=crossbar # conda environment for crossbar/ffbo processor
FFBO_ENV=ffbo # conda environment for main fbl
FFBO_DIR=$BASE/ffbo # directory to store local repositories
ORIENTDB_ROOT=$BASE/orientdb # root directory where you want to install OrientDB
FFBO_PORT=8081 # main port number of the FFBO processor, make sure to use an uncommon port that will not be used by other program
ORIENTDB_BINARY_PORT=2424 # Binary port of OrientDB, please change this if you are on running this on a multi-user machine to avoid running OrientDB on a wrong port
ORIENTDB_HTTP_PORT=2480 # HTTP port of OrientDB, please change this if you are on running this on a multi-user machine to avoid running OrientDB on a wrong port
DATABASE_MEMORY=8G # maximum amount of memory you want to assign to the database for java heap in GB
DATABASE_DISKCACHE=10240 # amount of memory assigned to caching disk in MB
PYTHON_VERSION=3.10 # specify python version (tested on python<=3.10)

# End of folder configuration.

echo "The following are the prerequisites that requires sudo to install:"
echo 
echo "-----------------------------------------------------"
echo
echo "sudo apt install -y wget default-jre curl build-essential tar apt-transport-https tmux sendmail graphviz graphviz-dev"
echo
echo "-----------------------------------------------------"
echo
echo "Please make sure that they are installed before continuing."
echo

while true
do
    read -p "continue? (Y/n) " -r
    case $REPLY in
        [Yy]* ) break
                ;;
        [Nn]* ) echo
                exit 0
                ;;
        "" )    break
                ;;
        * ) echo "Please answer yes or no. "
            ;;
    esac
done

# check if java exists
if ! command -v java &> /dev/null
then
    echo "java runtime environment is not installed. Please view step 1 in this script for a list of prerequisites."
fi

# check if tmux exists
if ! command -v tmux &> /dev/null
then
    echo "tmux is not installed. Please view step 1 in this script for a list of prerequisites."
fi

# check if java exists
if ! command -v wget &> /dev/null
then
    echo "wget is not installed. Please view step 1 in this script for a list of prerequisites."
fi

# check if CUDA exists
if ! command -v $CUDA_ROOT/bin/nvcc &> /dev/null
then
    echo "CUDA installation cannot be found. Please make sure to use the correct CUDA directory. If you don't have CUDA installed, go to https://developer.nvidia.com/cuda-downloads"
    exit
fi

# check if directories already exist
if [ -d "$FFBO_DIR" ]; then
    echo "$FFBO_DIR already exists, please remove before continue"
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

if [ -d "$CONDA_ROOT/envs/$CROSSBAR_ENV" ]; then
    echo "conda environment $CROSSBAR_ENV already exists, please remove or use a different name"
    exit 1
fi


#install orientdb
echo "Installing OrientDB ......"
wget https://repo1.maven.org/maven2/com/orientechnologies/orientdb-community/3.1.20/orientdb-community-3.1.20.tar.gz
tar zxf orientdb-community-3.1.20.tar.gz --directory .
mv orientdb-community-3.1.20 $ORIENTDB_ROOT
rm orientdb-community-3.1.20.tar.gz
sed -i -e '146i \ \ \ \ \ \ \ \ <entry name="network.token.expireTimeout" value="144000000"/>' $ORIENTDB_ROOT/config/orientdb-server-config.xml
sed -i '/<\/users>/i \
      <user resources="*" password="{PBKDF2WithHmacSHA256}CB55FC353E97910517F5E8811FC48BB89B7CDF9B66BF880C:A3664992731721A52998BEE95C1CA73BAA6093E91191FA1C:65536" name="root"/> \
      <user resources="connect,server.listDatabases,server.dblist" password="{PBKDF2WithHmacSHA256}289DE306D44BAAD7676BA04426F19A056B4CF8904BB80A71:001BFE74763F762037E7676752BF9D37F3A508A331BEB41C:65536" name="guest"/>' $ORIENTDB_ROOT/config/orientdb-server-config.xml
sed -i -e "s+2424-2430+$ORIENTDB_BINARY_PORT+g" $ORIENTDB_ROOT/config/orientdb-server-config.xml
sed -i -e "s+2480-2490+$ORIENTDB_HTTP_PORT+g" $ORIENTDB_ROOT/config/orientdb-server-config.xml

# Set orientdb root password to root
echo "export ORIENTDB_ROOT_PASSWORD=root" | tee -a ~/.bashrc
# Set orientdb memory limits, minimum set to 1GB, maximum set to 32GB.
# Change if you have less memory
echo "export ORIENTDB_OPTS_MEMORY='-Xms1G -Xmx$DATABASE_MEMORY' # increase or decrease Xmx to fit the memory size of your machine" | tee -a ~/.bashrc
# Set orientdb disk cache size to 10GB.
echo "export ORIENTDB_SETTINGS=-Dstorage.diskCache.bufferSize=$DATABASE_DISKCACHE # the amount of memory in MB used for disk cache. This plus Xmx above must be smaller than the total size of memory on your machine." | tee -a ~/.bashrc

# download packages
echo "Downloading packages"
mkdir $FFBO_DIR
cd $FFBO_DIR
git clone https://github.com/fruitflybrain/ffbo.processor.git
git clone https://github.com/fruitflybrain/crossbar.git
git clone https://github.com/fruitflybrain/ffbo.neuroarch_component.git
git clone https://github.com/fruitflybrain/neuroarch.git
git clone https://github.com/fruitflybrain/pyorient.git
git clone https://github.com/fruitflybrain/ffbo.nlp_component.git
git clone https://github.com/fruitflybrain/quepy.git
git clone https://github.com/fruitflybrain/ffbo.neuroarch_nlp.git
git clone https://github.com/fruitflybrain/DrosoBOT.git
git clone https://github.com/fruitflybrain/ffbo.neuronlp.git
cd ffbo.neuronlp
git checkout hemibrain
git clone https://github.com/fruitflybrain/ffbo.lib.git lib
cd ../
mkdir -p $FFBO_DIR/ffbo.neuronlp/img/flycircuit
git clone https://github.com/fruitflybrain/ffbo.neurokernel_component.git
git clone https://github.com/neurokernel/neurokernel.git
git clone https://github.com/neurokernel/neurodriver.git
git clone https://github.com/FlyBrainLab/FBLClient.git
git clone https://github.com/FlyBrainLab/Neuroballad.git
git clone https://github.com/FlyBrainLab/NeuroMynerva.git
git clone https://github.com/FlyBrainLab/Tutorials.git
git clone https://github.com/fruitflybrain/neu3d.git
git clone https://github.com/flybrainlab/NeuGFX.git
git clone https://github.com/FlyBrainLab/run_scripts.git
mkdir nk_tmp

. $CONDA_ROOT/etc/profile.d/conda.sh

echo "Installing FBL ......"
echo
echo "Installing crossbar environment for the ffbo.processor"
echo

conda create -n $CROSSBAR_ENV python=$PYTHON_VERSION numpy pandas -c conda-forge -y
conda activate $CROSSBAR_ENV
cd $FFBO_DIR/crossbar
python -m pip install .
cd $FFBO_DIR/ffbo.processor
python -m pip install -e .
conda deactivate

echo "Installing FFBO environments"
echo 
conda create -n $FFBO_ENV python=$PYTHON_VERSION python-snappy numpy matplotlib scipy pandas h5py nodejs cookiecutter yarn gdown -c conda-forge -y

# Install OpenMPI if cannot find a CUDA-aware openmpi installation
if ((command -v ompi_info &> /dev/null) && (ompi_info -a | grep "xtensions" | grep -q "cuda"))
then
    echo "Found OpenMPI with CUDA support, skipping OpenMPI installation."
else
    echo "Installing OpenMPI ......"
    conda activate $FFBO_ENV
    conda install openmpi mpi4py -c conda-forge -y
    conda env config vars set OMPI_MCA_opal_cuda_support=true
    conda deactivate
    # wget https://download.open-mpi.org/release/open-mpi/v4.0/openmpi-4.0.3.tar.gz
    # tar xzf openmpi-4.0.3.tar.gz
    # rm -rf openmpi-4.0.3.tar.gz
    # cd openmpi-4.0.3
    # ./configure --with-cuda=$CUDA_ROOT --disable-mpi-fortran --enable-shared --prefix=$CONDA_ROOT/envs/$FFBO_ENV
    # make -j8
    # make install
    # cd ../
    # rm -rf openmpi-4.0.3
    echo "OpenMPI installed"
fi

sleep 10s

conda activate $FFBO_ENV
if (( $(echo "$CUDA_VERSION < 11.3" |bc -l) )); then
    python -m pip install torch==1.12.0+cu102 torchvision==0.13.0+cu102 torchaudio==0.12.0 --extra-index-url https://download.pytorch.org/whl/cu102
elif (( $(echo "$CUDA_VERSION < 11.6" |bc -l) )); then
    python -m pip install torch==1.12.0+cu113 torchvision==0.13.0+cu113 torchaudio==0.12.0 --extra-index-url https://download.pytorch.org/whl/cu113
else
    python -m pip install torch==1.12.0+cu116 torchvision==0.13.0+cu116 torchaudio==0.12.0 --extra-index-url https://download.pytorch.org/whl/cu116
fi
python -m pip install numba
cd $FFBO_DIR/ffbo.nlp_component
python -m pip install -e .[drosobot]
cd $FFBO_DIR/DrosoBOT
python -m pip install -e .
cd $FFBO_DIR/ffbo.neuroarch_nlp
python -m pip install -e .
cd $FFBO_DIR/quepy
python -m pip install -e .
python -m spacy download en_core_web_sm
cd $FFBO_DIR/neuroarch
python -m pip install -e .
cd $FFBO_DIR/pyorient
python -m pip install -e .
cd $FFBO_DIR/ffbo.neuroarch_component
python -m pip install -e .
cd $FFBO_DIR/neurokernel
python -m pip install -e .
cd $FFBO_DIR/neurodriver
python -m pip install -e .
cd $FFBO_DIR/ffbo.neurokernel_component
python -m pip install -e .

cd $FFBO_DIR/Neuroballad
python -m pip install -e .
cd $FFBO_DIR/FBLClient
python -m pip install -e .[full]
cd $FFBO_DIR/neu3d
git checkout dev
npm install
npm run build
cd $FFBO_DIR/NeuroMynerva
python -m pip install -e .
jupyter labextension develop . --overwrite
jlpm run build
cd $FFBO_DIR/neu3d
jlpm link
cd $FFBO_DIR/NeuroMynerva
jlpm link 'neu3d' 
jlpm run build
cd $FFBO_DIR/NeuGFX
git checkout local_files
npm install --legacy-peer-deps
npm install webpack@latest --legacy-peer-deps
npm update --legacy-peer-deps
npm install util --legacy-peer-deps
npm i --save-dev process --legacy-peer-deps
npm run build --legacy-peer-deps
conda deactivate

mkdir -p $HOME/.jupyter/lab/user-settings/@flybrainlab/neuromynerva
wget https://cdn.jsdelivr.net/gh/flybrainlab/NeuroMynerva@master/schema/plugin.json.local -O $HOME/.jupyter/lab/user-settings/@flybrainlab/neuromynerva/plugin.jupyterlab-settings
sed -i -e "s+8081+$FFBO_PORT+g" $HOME/.jupyter/lab/user-settings/@flybrainlab/neuromynerva/plugin.jupyterlab-settings


mkdir -p ~/.ffbo/config
cp $FFBO_DIR/ffbo.processor/config.ini ~/.ffbo/config/config.ini
sed -i -e "11,15d; 26,29d; s+8081+$FFBO_PORT+g; s+2424+$ORIENTDB_BINARY_PORT+g; s+2480+$ORIENTDB_HTTP_PORT+g" ~/.ffbo/config/config.ini

cp -r $FFBO_DIR/run_scripts/flybrainlab $FFBO_DIR/bin
cd $FFBO_DIR/bin
sed -i -e "s+{FFBO_DIR}+$FFBO_DIR+g; s+{FFBO_ENV}+$FFBO_ENV+g;" download_datasets.sh
sed -i -e "s+{FFBO_DIR}+$FFBO_DIR+g; s+{FFBO_ENV}+$FFBO_ENV+g;" download_drosobot_data.sh
sed -i -e "s+{FFBO_DIR}+$FFBO_DIR+g; s+{FFBO_ENV}+$FFBO_ENV+g; s+{CROSSBAR_ENV}+$CROSSBAR_ENV+g" run_processor.sh
sed -i -e "s+{FFBO_DIR}+$FFBO_DIR+g; s+{FFBO_ENV}+$FFBO_ENV+g" run_nlp.sh
sed -i -e "s+{FFBO_DIR}+$FFBO_DIR+g; s+{FFBO_ENV}+$FFBO_ENV+g" run_neuroarch.sh
# sed -i -e "s+component.py+& --port $ORIENTDB_BINARY_PORT+" run_neuroarch.sh
sed -i -e "s+{FFBO_DIR}+$FFBO_DIR+g; s+{FFBO_ENV}+$FFBO_ENV+g" run_neurokernel.sh
sed -i -e "s+{ORIENTDB_ROOT}+$ORIENTDB_ROOT+g" run_database.sh
sed -i -e "s+{FFBO_DIR}+$FFBO_DIR+g; s+{FFBO_ENV}+$FFBO_ENV+g" run_fbl.sh
sed -i -e "s+{FFBO_DIR}+$FFBO_DIR+g; s+{ORIENTDB_ROOT}+$ORIENTDB_ROOT+g" start.sh
sed -i -e "s+{ORIENTDB_ROOT}+$ORIENTDB_ROOT+g; s+{ORIENTDB_BINARY_PORT}+$ORIENTDB_BINARY_PORT+g" shutdown.sh
sed -i -e "s+{FFBO_DIR}+$FFBO_DIR+g; s+{FFBO_ENV}+$FFBO_ENV+g; s+{CROSSBAR_ENV}+$CROSSBAR_ENV+g" update_local_repo.sh
mv update_local_repo.sh update.sh
rm -rf $FFBO_DIR/run_scripts
$FFBO_DIR/bin/download_drosobot_data.sh $FFBO_DIR/ffbo.nlp_component/nlp_component/data

echo "Installation complete. Downloading databases ......"
cd $FFBO_DIR/bin
./download_datasets.sh $ORIENTDB_ROOT

echo

echo "Done! This set up only allows you to run one set of frontend/backend on your system"

echo
echo "Log out and back in again to before starting FlyBrainLab."
echo "To start FlyBrainLab, run $FFBO_DIR/bin/start.sh."
echo "Closing jupyter will not terminate the backend servers. To start jupyter again, run $FFBO_DIR/bin/run_fbl.sh."
echo "To shutdown all FlyBrainLab processes, run $FFBO_DIR/bin/shutdown.sh."
echo
