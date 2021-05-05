# Build Docker for FlyBrainLab
# docker build -f Dockerfile --build-arg FLYBRAINLAB_DOCKER_VER=$(date +%Y%m%d-%H%M%S) -t fruitflybrain/fbl .

FROM nvidia/cuda:11.2.1-devel-ubuntu18.04

LABEL maintainer="Fruit Fly Brain Observatory Team <http://fruitflybrain.org>"

RUN apt-get update && apt-get upgrade -y && apt-get install -y openssh-server emacs sudo tmux git default-jre curl vim wget dialog net-tools build-essential tar apt-transport-https whois sendmail graphviz graphviz-dev && \
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

RUN wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda.sh &&  \
    sh miniconda.sh -b -p /home/ffbo/miniconda && \
    echo ". $HOME/miniconda/etc/profile.d/conda.sh" | tee -a ~/.bashrc && \
    rm miniconda.sh && \
    mkdir /home/ffbo/ffbo && \
    cd /home/ffbo/ffbo && \
    git clone https://github.com/fruitflybrain/ffbo.nlp_component.git && \
    git clone https://github.com/fruitflybrain/ffbo.processor.git && \
    git clone https://github.com/fruitflybrain/ffbo.neuroarch_component.git && \
    git clone https://github.com/fruitflybrain/ffbo.neurokernel_component.git && \
    git clone https://github.com/fruitflybrain/ffbo.neuronlp.git  && \
    cd ffbo.neuronlp && \
    git checkout hemibrain && \
    git clone https://github.com/fruitflybrain/ffbo.lib.git lib && \
    cd lib && \
    git checkout hemibrain && \
    cd ../../ && \
    mkdir -p /home/ffbo/ffbo/ffbo.neuronlp/img/flycircuit && \
    git clone https://github.com/FlyBrainLab/Tutorials.git && \
    mkdir nk_tmp && \
    /bin/bash -c ". $HOME/miniconda/etc/profile.d/conda.sh && \
    conda create -n crossbar python=3.7 numpy pandas -c conda-forge -y && \
    conda activate crossbar && \
    cd /home/ffbo/ffbo/ffbo.processor && \
    python -m pip install -e . && \
    conda deactivate && \
    conda create -n ffbo_legacy python=2.7 numpy -y && \
    conda activate ffbo_legacy && \
    cd /home/ffbo/ffbo/ffbo.nlp_component && \
    pip install -r requirements.txt && \
    python -m pip install -e . && \
    conda deactivate && \
    conda create -n ffbo python=3.7 python-snappy numpy matplotlib scipy pandas h5py -c conda-forge -y && \
    conda activate ffbo && \
    python -m pip install git+https://github.com/fruitflybrain/pyorient.git git+https://github.com/mkturkcan/autobahn-sync.git git+https://github.com/FlyBrainLab/Neuroballad.git git+https://github.com/palash1992/GEM.git git+https://github.com/mkturkcan/nxcontrol && \
    python -m pip install neurokernel neurodriver neuroarch flybrainlab[full] neuromynerva && \
    cd /home/ffbo/ffbo/ffbo.neuroarch_component && \
    python -m pip install -e . && \
    cd /home/ffbo/ffbo/ffbo.neurokernel_component && \
    python -m pip install -e ." && \
    cd /home/ffbo/ && \
    wget https://github.com/explosion/spaCy/releases/download/v1.6.0/en-1.1.0.tar.gz && \
    mkdir /home/ffbo/miniconda/envs/ffbo_legacy/lib/python2.7/site-packages/spacy/data && \
    tar zxf en-1.1.0.tar.gz --directory /home/ffbo/miniconda/envs/ffbo_legacy/lib/python2.7/site-packages/spacy/data && \
    rm en-1.1.0.tar.gz && \
    rm -rf /home/ffbo/.cache

# line 222 of process.py is: print(line.rstrip())

#sed -i.bak -e '100,103d' /home/ffbo/miniconda/envs/ffbo/lib/python3.7/site-packages/pyorient/orient.py && \
#sed -i.bak -e '31 a\ \ \ \ \ \ \ \ self.client.set_session_token(True)' /home/ffbo/miniconda/envs/ffbo/lib/python3.7/site-packages/pyorient/ogm/graph.py && \

ARG FLYBRAINLAB_DOCKER_VER=unknown

RUN /bin/bash -c ". $HOME/miniconda/etc/profile.d/conda.sh && \
    conda activate ffbo_legacy && \
    cd /home/ffbo/ffbo/ffbo.nlp_component && \
    python -m pip install --upgrade git+https://github.com/fruitflybrain/ffbo.neuroarch_nlp.git && \
    cd /home/ffbo/ffbo/ffbo.nlp_component && \
    git pull && python -m pip install -e . && \
    conda deactivate && \
    conda activate crossbar && \
    cd /home/ffbo/ffbo/ffbo.processor && \
    git pull && python -m pip install -e . && \
    conda deactivate && \
    conda activate ffbo && \
    cd /home/ffbo/ffbo/ffbo.neuroarch_component && \
    git pull && python -m pip install -e . && \
    cd /home/ffbo/ffbo/ffbo.neurokernel_component && \
    git pull && python -m pip install -e . && \
    python -m pip install --upgrade neuroarch neurokernel neurodriver git+https://github.com/flybrainlab/Neuroballad.git flybrainlab[full] neuromynerva" && \
    cd /home/ffbo/ffbo/Tutorials && git pull && \
    rm -rf /home/ffbo/.cache

RUN mkdir -p /home/ffbo/.ffbo/config && \
    cp /home/ffbo/ffbo/ffbo.processor/config.ini /home/ffbo/.ffbo/config/ && \
    sed -i -e "11,15d; 26,29d; s+8081+8081+g" /home/ffbo/.ffbo/config/config.ini && \
    git clone https://github.com/FlyBrainLab/run_scripts.git && \
    cp -r run_scripts/flybrainlab /home/ffbo/ffbo/bin && \
    cd /home/ffbo/ffbo/bin && \
    rm update_local_repo.sh && \
    sed -i -e "s+{FFBO_DIR}+/home/ffbo/ffbo+g; s+{FFBO_ENV}+ffbo+g; s+{CROSSBAR_ENV}+crossbar+g; s+\$(conda info --base)+/home/ffbo/miniconda+g" run_processor.sh && \
    sed -i -e "s+{FFBO_DIR}+/home/ffbo/ffbo+g; s+{NLP_ENV}+ffbo_legacy+g; s+\$(conda info --base)+/home/ffbo/miniconda+g" run_nlp.sh && \
    sed -i -e "s+{FFBO_DIR}+/home/ffbo/ffbo+g; s+{FFBO_ENV}+ffbo+g; s+\$(conda info --base)+/home/ffbo/miniconda+g" run_neuroarch.sh && \
    sed -i -e "s+{FFBO_DIR}+/home/ffbo/ffbo+g; s+{FFBO_ENV}+ffbo+g; s+\$(conda info --base)+/home/ffbo/miniconda+g" run_neurokernel.sh && \
    sed -i -e "s+{ORIENTDB_ROOT}+/home/ffbo/orientdb+g" run_database.sh && \
    sed -i -e "s+{FFBO_DIR}+/home/ffbo/ffbo+g; s+{FFBO_ENV}+ffbo+g; s+\$(conda info --base)+/home/ffbo/miniconda+g" run_fbl.sh && \
    sed -i -e "s+{FFBO_DIR}+/home/ffbo/ffbo+g; s+{ORIENTDB_ROOT}+/home/ffbo/orientdb+g" start.sh && \
    sed -i -e "s+{ORIENTDB_ROOT}+/home/ffbo/orientdb+g; s+{ORIENTDB_BINARY_PORT}+2424+g; " shutdown.sh && \
    sed -i -e "s+{FFBO_DIR}+/home/ffbo/ffbo+g; s+{FFBO_ENV}+ffbo+g; s+{NLP_ENV}+ffbo_legacy+g; s+{CROSSBAR_ENV}+crossbar+g; s+\$(conda info --base)+/home/ffbo/miniconda+g" update.sh && \
    rm -rf /home/ffbo/run_scripts && \
    mkdir -p /home/ffbo/.jupyter/lab/user-settings/@flybrainlab/neuromynerva && \
    wget https://raw.githubusercontent.com/FlyBrainLab/NeuroMynerva/master/schema/plugin.json.local -O /home/ffbo/.jupyter/lab/user-settings/@flybrainlab/neuromynerva/plugin.jupyterlab-settings && \
    echo "export ORIENTDB_ROOT_PASSWORD=root" | tee -a ~/.bashrc && \
    echo 'export ORIENTDB_OPTS_MEMORY="-Xms1G -Xmx8G" # increase or decrease Xmx to fit the memory size of your machine' | tee -a ~/.bashrc && \
    echo "export ORIENTDB_SETTINGS=-Dstorage.diskCache.bufferSize=10240 # the amount of memory in MB used for disk cache. This plus Xmx above must be smaller than the total size of memory on your machine." | tee -a ~/.bashrc

ENV ORIENTDB_ROOT_PASSWORD=root \
    ORIENTDB_OPTS_MEMORY="-Xms1G -Xmx8G" \
    ORIENTDB_SETTINGS=-Dstorage.diskCache.bufferSize=10240

SHELL ["/bin/bash", "-c"]
CMD /home/ffbo/ffbo/bin/download_datasets.sh /home/ffbo/orientdb && /home/ffbo/ffbo/bin/start.sh
