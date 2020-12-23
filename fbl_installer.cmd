
pip install jupyter "jupyterlab>=2.2.8" & ^
pip install txaio autobahn[twisted] crochet service_identity matplotlib h5py seaborn fastcluster networkx msgpack msgpack-numpy & ^
pip install git+https://github.com/mkturkcan/autobahn-sync.git & ^
pip install pypiwin32 & ^
mkdir fbl_installation & ^
cd fbl_installation & ^
git clone https://github.com/FlyBrainLab/Neuroballad.git & ^
git clone https://github.com/FlyBrainLab/FBLClient.git & ^
cd ./Neuroballad & ^
python setup.py develop & ^
cd ../FBLClient & ^
python setup.py develop & ^
jupyter labextension install @flybrainlab/neuromynerva
