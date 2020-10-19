conda install nodejs scipy pandas cookiecutter git yarn -c conda-forge -y
pip install jupyter jupyterlab==2.1.5
pip install txaio twisted autobahn crochet service_identity autobahn-sync matplotlib h5py seaborn fastcluster networkx msgpack
mkdir FlyBrainLab
cd FlyBrainLab
git clone https://github.com/FlyBrainLab/Neuroballad.git
git clone https://github.com/FlyBrainLab/FBLClient.git
git clone https://github.com/FlyBrainLab/NeuroMynerva.git
cd ./Neuroballad
python setup.py develop
cd ../FBLClient
python setup.py develop
cd ../NeuroMynerva
jlpm || true
jlpm run build || true
jupyter labextension install . || true
jupyter lab build || true
jupyter lab || true