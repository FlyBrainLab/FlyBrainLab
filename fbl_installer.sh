conda install nodejs scipy pandas jupyterlab cookiecutter git yarn -c conda-forge -y
pip install txaio twisted autobahn crochet service_identity autobahn-sync matplotlib h5py seaborn fastcluster networkx jupyter
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
yarn install || true
npm run build || true
npm run build || true
npm run link || true
jupyter lab build