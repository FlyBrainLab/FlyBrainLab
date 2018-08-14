# Initial setup
FROM continuumio/miniconda3
MAINTAINER FlyBrainLab <x@gmail.com>
ADD . /code
WORKDIR /code

#Set up apt-get
RUN apt-get update && apt-get install -y --allow-unauthenticated apt-transport-https
RUN echo "deb http://archive.ubuntu.com/ubuntu/ trusty main universe" >> /etc/apt/sources.list
RUN apt-get update


# Install basic applications
RUN apt-get install -y build-essential

#Python dependencies
RUN conda create -n neuromynerva python=3.6 nodejs scipy pandas jupyterlab cookiecutter git yarn -c conda-forge
#NOTE: This is not recommended, but it does work
ENV PATH /opt/conda/envs/neuromynerva/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
RUN pip install txaio twisted autobahn crochet service_identity autobahn-sync matplotlib h5py seaborn networkx
RUN git clone https://github.com/FlyBrainLab/Neuroballad.git
WORKDIR ./Neuroballad
RUN python setup.py develop
WORKDIR ..
RUN git clone https://github.com/FlyBrainLab/FBLClient.git
WORKDIR ./FBLClient
RUN python setup.py develop

#NPM dependencies
WORKDIR ..
RUN git clone https://github.com/FlyBrainLab/FlyBrainLab.git
RUN git clone https://github.com/FlyBrainLab/NeuroMynerva.git
WORKDIR ./NeuroMynerva
RUN yarn install
# Currently requires two npm run builds to work
# exit 0 used to ignore first npm run build's fail
RUN npm run build; exit 0
RUN npm run build && npm run link

WORKDIR ..

RUN jupyter lab build

#Launch app
CMD jupyter lab --allow-root --ip=$(hostname -I)
