conda create -n fbl_installation python=3.7 -y
activate fbl_installation
conda install nodejs scipy pandas cookiecutter git yarn -c conda-forge -y
pip install jupyter jupyterlab==2.1.5
pip install txaio twisted autobahn crochet service_identity autobahn-sync matplotlib h5py seaborn fastcluster networkx msgpack
pip install pypiwin32
mkdir fbl_installation
cd fbl_installation
git clone https://github.com/FlyBrainLab/Neuroballad.git
git clone https://github.com/FlyBrainLab/FBLClient.git
git clone https://github.com/FlyBrainLab/NeuroMynerva.git
cd ./Neuroballad
python setup.py develop
cd ../FBLClient
python setup.py develop
cd ../NeuroMynerva
jlpm & jlpm run build & jupyter labextension install . & jupyter lab build & jupyter lab