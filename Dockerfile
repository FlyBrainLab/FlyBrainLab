# Build Docker for FlyBrainLab
# docker build -f Dockerfile --build-arg FLYBRAINLAB_DOCKER_VER=$(date +%Y%m%d-%H%M%S) -t fruitflybrain/fbl .

FROM nvidia/cuda:10.2-devel-ubuntu18.04

LABEL maintainer="Fruit Fly Brain Observatory Team <http://fruitflybrain.org>"

RUN apt-get update && apt-get install -y openssh-server emacs sudo tmux git default-jre curl vim wget dialog net-tools build-essential tar apt-transport-https whois && \
    mkdir /var/run/sshd && \
    echo 'root:kfj8734KJFhu28fDFuhuew9,2481' | chpasswd && \
    sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd && \
    echo "export VISIBLE=now" >> /etc/profile && \
    useradd ffbo -m -s /bin/bash -p `mkpasswd Drosophila` && \
    usermod -aG sudo ffbo && \
    apt-get clean  && \
    apt-get autoremove --purge

ENV NOTVISIBLE="in users profile"
EXPOSE 22

RUN wget https://download.open-mpi.org/release/open-mpi/v4.0/openmpi-4.0.5.tar.gz &&\
    tar xzf openmpi-4.0.5.tar.gz && \
    rm -rf openmpi-4.0.5.tar.gz && \
    cd openmpi-4.0.5 && \
    ./configure --with-cuda=/usr/local/cuda --disable-mpi-fortran --enable-shared --prefix=/usr/local &&\
    make -j8 && \
    make install && \
    cd ../ && \
    rm -rf openmpi-4.0.5

USER ffbo
WORKDIR /home/ffbo

ENV PATH /usr/local/bin:/usr/local/cuda/bin:/usr/bin:/usr/sbin:$PATH
ENV LD_LIBRARY_PATH /usr/local/lib:/usr/local/cuda/lib64:/usr/lib:/usr/lib/x86_64-linux-gnu:$LD_LIBRARY_PATH

RUN wget https://s3.us-east-2.amazonaws.com/orientdb3/releases/3.0.35/orientdb-3.0.35.tar.gz && \
    tar zxf orientdb-3.0.35.tar.gz --directory /home/ffbo/ && \
    mv /home/ffbo/orientdb-3.0.35 /home/ffbo/orientdb && \
    rm orientdb-3.0.35.tar.gz

RUN wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda.sh && \
    sh miniconda.sh -b -p /home/ffbo/miniconda && \
    echo ". $HOME/miniconda/etc/profile.d/conda.sh" | tee -a ~/.bashrc && \
    rm miniconda.sh && \
    mkdir /home/ffbo/ffbo && \
    cd /home/ffbo/ffbo && \
    git clone https://github.com/fruitflybrain/ffbo.nlp_component.git && \
    git clone https://github.com/fruitflybrain/ffbo.neuroarch_nlp.git && \
    git clone https://github.com/fruitflybrain/quepy.git && \
    git clone https://github.com/fruitflybrain/ffbo.processor.git && \
    git clone https://github.com/fruitflybrain/ffbo.neuroarch_component.git && \
    git clone https://github.com/fruitflybrain/neuroarch.git && \
    git clone https://github.com/fruitflybrain/ffbo.neurokernel_component.git && \
    git clone https://github.com/fruitflybrain/ffbo.neuronlp.git  && \
    cd ffbo.neuronlp && \
    git checkout hemibrain && \
    git clone https://github.com/fruitflybrain/ffbo.lib.git lib && \
    cd lib && \
    git checkout hemibrain && \
    cd ../../ && \
    mkdir -p /home/ffbo/ffbo/ffbo.neuronlp/img/flycircuit && \
    git clone https://github.com/FlyBrainLab/Neuroballad.git && \
    git clone https://github.com/FlyBrainLab/FBLClient.git && \
    git clone https://github.com/FlyBrainLab/NeuroMynerva.git && \
    git clone https://github.com/FlyBrainLab/Tutorials.git && \
    git clone https://github.com/neurokernel/neurokernel.git && \
    git clone https://github.com/neurokernel/neurodriver.git && \
    git clone https://github.com/neurokernel/retina.git && \
    mkdir nk_tmp && \
    /bin/bash -c ". $HOME/miniconda/etc/profile.d/conda.sh && \
    conda create -n ffbo_legacy python=2.7 numpy -y && \
    conda activate ffbo_legacy && \
    pip install autobahn[twisted] configparser docopt sparqlwrapper nltk spacy==1.6.0 fuzzywuzzy python-levenshtein pyopenssl plac==0.9.6 service_identity && \
    conda deactivate && \
    conda create -n ffbo python=3.7 nodejs cookiecutter git yarn python-snappy -c conda-forge -y && \
    conda activate ffbo && \
    #export PATH=/usr/local/bin:/usr/local/cuda/bin:$PATH && \
    #export LD_LIBRARY_PATH=/usr/local/lib:/usr/local/cuda/lib64:$LD_LIBRARY_PATH && \
    pip install numpy matplotlib scipy pandas crossbar jupyter 'jupyterlab>=2.2.8' autobahn[twisted] beautifulsoup4 tinydb simplejson configparser docopt sparqlwrapper python-levenshtein pyopenssl service_identity plac==0.9.6 datadiff refo msgpack msgpack-numpy pyorient_native daff path.py txaio crochet autobahn-sync seaborn fastcluster networkx h5py jupyter 'mpmath>=0.19' sympy nose tqdm && \
    pip install git+https://github.com/fruitflybrain/pyorient.git && \
    pip install pycuda mpi4py" && \
    cd /home/ffbo/ && \
    wget https://github.com/explosion/spaCy/releases/download/v1.6.0/en-1.1.0.tar.gz && \
    mkdir /home/ffbo/miniconda/envs/ffbo_legacy/lib/python2.7/site-packages/spacy/data && \
    tar zxf en-1.1.0.tar.gz --directory /home/ffbo/miniconda/envs/ffbo_legacy/lib/python2.7/site-packages/spacy/data && \
    rm en-1.1.0.tar.gz && \
    sed -i.bak -e '222d' /home/ffbo/miniconda/envs/ffbo/lib/python3.7/site-packages/jupyterlab_server/process.py && \
    sed -i.bak -e '77d; /^    def call(.*/i \ \ \ \ @crochet.wait_for(timeout=2**31)' /home/ffbo/miniconda//envs/ffbo/lib/python3.7/site-packages/autobahn_sync/session.py && \
    rm -rf /home/ffbo/.cache

# line 222 of process.py is: print(line.rstrip())

#sed -i.bak -e '100,103d' /home/ffbo/miniconda/envs/ffbo/lib/python3.7/site-packages/pyorient/orient.py && \
#sed -i.bak -e '31 a\ \ \ \ \ \ \ \ self.client.set_session_token(True)' /home/ffbo/miniconda/envs/ffbo/lib/python3.7/site-packages/pyorient/ogm/graph.py && \


RUN /bin/bash -c ". $HOME/miniconda/etc/profile.d/conda.sh && \
    conda activate ffbo_legacy && \
    cd /home/ffbo/ffbo/ffbo.nlp_component && \
    git pull && git checkout master && git pull && \
    python setup.py develop && \
    cd /home/ffbo/ffbo/ffbo.neuroarch_nlp && \
    git pull && git checkout master && git pull && \
    python setup.py develop && \
    cd /home/ffbo/ffbo/quepy && \
    git pull && git checkout apps && git pull && \
    python setup.py develop && \
    conda deactivate && \
    conda activate ffbo && \
    cd /home/ffbo/ffbo/ffbo.processor && \
    git pull && git checkout master && git pull && \
    python setup.py develop && \
    cd /home/ffbo/ffbo/ffbo.neuroarch_component && \
    git pull && git checkout master && git pull && \
    python setup.py develop && \
    cd /home/ffbo/ffbo/neuroarch && \
    git pull && git checkout master && git pull && \
    python setup.py develop && \
    cd /home/ffbo/ffbo/ffbo.neurokernel_component && \
    git pull && git checkout master && git pull && \
    python setup.py develop && \
    cd /home/ffbo/ffbo/neurokernel && \
    git pull && git checkout managerless && git pull && \
    python setup.py develop && \
    cd /home/ffbo/ffbo/neurodriver && \
    git pull && git checkout fbl && git pull && \
    python setup.py develop && \
    cd /home/ffbo/ffbo/retina && \
    git pull && git checkout master && git pull && \
    python setup.py develop && \
    cd /home/ffbo/ffbo/Neuroballad && \
    git pull && git checkout master && git pull && \
    python setup.py develop && \
    cd /home/ffbo/ffbo/FBLClient && \
    git pull && git checkout master && git pull && \
    python setup.py develop && \
    cd /home/ffbo/ffbo/NeuroMynerva && \
    jlpm && jlpm run build &&  jupyter labextension install ." && \
    rm -rf /home/ffbo/.cache

#jupyter labextension install @flybrainlab/neuromynerva && \

ARG FLYBRAINLAB_DOCKER_VER=unknown

RUN cd /home/ffbo/ffbo/ffbo.nlp_component && \
    git pull && \
    cd /home/ffbo/ffbo/ffbo.neuroarch_nlp && \
    git pull && \
    cd /home/ffbo/ffbo/ffbo.processor && \
    git pull && \
    cd /home/ffbo/ffbo/ffbo.neuroarch_component && \
    git pull && \
    cd /home/ffbo/ffbo/neuroarch && \
    git pull && \
    cd /home/ffbo/ffbo/neurokernel && \
    git pull && \
    cd /home/ffbo/ffbo/neurodriver && \
    git pull && \
    cd /home/ffbo/ffbo/retina && \
    git pull && \
    cd /home/ffbo/ffbo/Neuroballad && \
    git pull && \
    cd /home/ffbo/ffbo/FBLClient && \
    git pull && \
    cd /home/ffbo/ffbo/Tutorials && \
    git fetch && git pull && \
    git checkout master && git pull && \
    rm -rf /tmp/*.*

RUN mkdir -p /home/ffbo/.ffbo/config && \
    cp /home/ffbo/ffbo/ffbo.processor/config.ini /home/ffbo/.ffbo/config/ && \
    sed -i -e "11,15d; 26,29d; s+8081+8081+g" /home/ffbo/.ffbo/config/config.ini && \
    git clone https://github.com/FlyBrainLab/run_scripts.git && \
    cp -r run_scripts/flybrainlab /home/ffbo/ffbo/bin && \
    cd /home/ffbo/ffbo/bin && \
    sed -i -e "s+{FFBO_DIR}+/home/ffbo/ffbo+g; s+{FFBO_ENV}+ffbo+g; s+\$(conda info --base)+/home/ffbo/miniconda+g" run_processor.sh && \
    sed -i -e "s+{FFBO_DIR}+/home/ffbo/ffbo+g; s+{NLP_ENV}+ffbo_legacy+g; s+\$(conda info --base)+/home/ffbo/miniconda+g" run_nlp.sh && \
    sed -i -e "s+{FFBO_DIR}+/home/ffbo/ffbo+g; s+{FFBO_ENV}+ffbo+g; s+\$(conda info --base)+/home/ffbo/miniconda+g" run_neuroarch.sh && \
    sed -i -e "s+{FFBO_DIR}+/home/ffbo/ffbo+g; s+{FFBO_ENV}+ffbo+g; s+\$(conda info --base)+/home/ffbo/miniconda+g" run_neurokernel.sh && \
    sed -i -e "s+{ORIENTDB_ROOT}+/home/ffbo/orientdb+g" run_database.sh && \
    sed -i -e "s+{FFBO_DIR}+/home/ffbo/ffbo+g; s+{FFBO_ENV}+ffbo+g; s+\$(conda info --base)+/home/ffbo/miniconda+g" run_fbl.sh && \
    sed -i -e "s+{FFBO_DIR}+/home/ffbo/ffbo+g" start.sh && \
    sed -i -e "s+{ORIENTDB_ROOT}+/home/ffbo/orientdb+g" shutdown.sh && \
    sed -i -e "s+{FFBO_DIR}+/home/ffbo/ffbo+g" update.sh && \
    sed -i -e "s+{FFBO_DIR}+/home/ffbo/ffbo+g; s+{FFBO_ENV}+ffbo+g; s+\$(conda info --base)+/home/ffbo/miniconda+g" update_NeuroMynerva.sh && \
    rm -rf /home/ffbo/run_scripts && \
    wget https://raw.githubusercontent.com/FlyBrainLab/NeuroMynerva/master/schema/plugin.json.local -O /home/ffbo/miniconda/envs/ffbo/share/jupyter/lab/schemas/\@flybrainlab/neuromynerva/plugin.json && \
    echo "export ORIENTDB_ROOT_PASSWORD=root" | tee -a ~/.bashrc && \
    echo 'export ORIENTDB_OPTS_MEMORY="-Xms1G -Xmx8G" # increase or decrease Xmx to fit the memory size of your machine' | tee -a ~/.bashrc && \
    echo "export ORIENTDB_SETTINGS=-Dstorage.diskCache.bufferSize=10240 # the amount of memory in MB used for disk cache. This plus Xmx above must be smaller than the total size of memory on your machine." | tee -a ~/.bashrc

ENV ORIENTDB_ROOT_PASSWORD=root \
    ORIENTDB_OPTS_MEMORY="-Xms1G -Xmx8G" \
    ORIENTDB_SETTINGS=-Dstorage.diskCache.bufferSize=10240

SHELL ["/bin/bash", "-c"]
CMD /home/ffbo/ffbo/bin/download_datasets.sh /home/ffbo/orientdb && /home/ffbo/ffbo/bin/start.sh
