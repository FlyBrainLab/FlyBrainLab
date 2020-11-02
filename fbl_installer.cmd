conda install nodejs scipy pandas cookiecutter git yarn -c conda-forge -y
pip install jupyter jupyterlab>=2.2.8
pip install txaio twisted autobahn crochet service_identity autobahn-sync matplotlib h5py seaborn fastcluster networkx msgpack
pip install pypiwin32
mkdir fbl_installation
cd fbl_installation
git clone https://github.com/FlyBrainLab/Neuroballad.git
git clone https://github.com/FlyBrainLab/FBLClient.git
cd ./Neuroballad
python setup.py develop
cd ../FBLClient
python setup.py develop
jupyter labextension install @flybrainlab/neuromynerva
