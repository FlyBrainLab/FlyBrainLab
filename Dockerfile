# Build Docker for FlyBrainLab
# docker build -f Dockerfile --build-arg FLYBRAINLAB_DOCKER_VER=$(date +%Y%m%d-%H%M%S) -t fruitflybrain/fbl .

FROM fruitflybrain/base_os:ubuntu20.04-cuda11.3.1

LABEL maintainer="Fruit Fly Brain Observatory Team <http://fruitflybrain.org>"

ENV NOTVISIBLE="in users profile"
EXPOSE 22

USER ffbo
WORKDIR /home/ffbo

ENV PATH /usr/local/bin:/usr/local/cuda/bin:/usr/bin:/usr/sbin:$PATH
ENV LD_LIBRARY_PATH /usr/local/lib:/usr/local/cuda/lib64:/usr/lib:/usr/lib/x86_64-linux-gnu:$LD_LIBRARY_PATH
ENV OMPI_MCA_opal_cuda_support true

RUN wget https://repo1.maven.org/maven2/com/orientechnologies/orientdb-community/3.1.17/orientdb-community-3.1.17.tar.gz && \
    tar zxf orientdb-community-3.1.17.tar.gz --directory /home/ffbo/ && \
    mv /home/ffbo/orientdb-community-3.1.17 /home/ffbo/orientdb && \
    rm orientdb-community-3.1.17.tar.gz && \
    sed -i -e '146i \ \ \ \ \ \ \ \ <entry name="network.token.expireTimeout" value="144000000"/>' /home/ffbo/orientdb/config/orientdb-server-config.xml && \
    mkdir /home/ffbo/ffbo

RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda.sh && \
    bash miniconda.sh -b -p /home/ffbo/miniconda && \
    echo ". $HOME/miniconda/etc/profile.d/conda.sh" | tee -a ~/.bashrc && \
    rm miniconda.sh && \
    cd /home/ffbo/ffbo && \
    git clone https://github.com/fruitflybrain/ffbo.nlp_component.git && \
    git clone https://github.com/fruitflybrain/ffbo.processor.git && \
    git clone https://github.com/fruitflybrain/ffbo.neuroarch_component.git && \
    git clone https://github.com/fruitflybrain/ffbo.neuronlp.git && \
    cd ffbo.neuronlp && \
    git clone https://github.com/fruitflybrain/ffbo.lib.git lib  && \
    cd ../ && \
    git clone https://github.com/flybrainlab/NeuGFX  && \
    git clone https://github.com/fruitflybrain/ffbo.neurokernel_component.git && \
    mkdir -p /home/ffbo/ffbo/ffbo.neuronlp/img/flycircuit && \
    git clone https://github.com/FlyBrainLab/Tutorials.git && \
    mkdir nk_tmp

RUN /bin/bash -c ". $HOME/miniconda/etc/profile.d/conda.sh && \
    conda create -n crossbar python=3.9 numpy pandas -c conda-forge -y && \
    conda activate crossbar && \
    cd /home/ffbo/ffbo/ffbo.processor && \
    python -m pip install -e . && \
    conda deactivate" && \
    rm -rf /home/ffbo/.cache

RUN /bin/bash -c ". $HOME/miniconda/etc/profile.d/conda.sh && \
    conda create -n ffbo python=3.9 python-snappy numpy matplotlib scipy pandas h5py openmpi mpi4py nodejs cookiecutter yarn -c conda-forge -y && \
    conda activate ffbo && \
    python -m pip install torch==1.12.0+cu113 torchvision==0.13.0+cu113 torchaudio==0.12.0 --extra-index-url https://download.pytorch.org/whl/cu113 && \
    python -m pip install numba && \
    cd /home/ffbo/ffbo/ffbo.nlp_component && \
    python -m pip install -e .[drosobot] && \
    python -m spacy download en_core_web_sm && \
    cd /home/ffbo/ffbo/ffbo.neuroarch_component && \
    python -m pip install -e . && \
    cd /home/ffbo/ffbo/ffbo.neurokernel_component && \
    python -m pip install -e . && \
    python -m pip install git+https://github.com/fruitflybrain/pyorient_native git+https://github.com/fruitflybrain/pyorient" && \
    rm -rf /home/ffbo/.cache

RUN /bin/bash -c ". $HOME/miniconda/etc/profile.d/conda.sh && \
    conda activate ffbo && \
    python -m pip install git+https://github.com/mkturkcan/autobahn-sync.git \
                          git+https://github.com/FlyBrainLab/Neuroballad.git \
                          nxt_gem==2.0.1 \
                          git+https://github.com/mkturkcan/nxcontrol.git \
                          flybrainlab\[full\] \
                          neuromynerva && \
    cd /home/ffbo/ffbo/NeuGFX && \
    git checkout local_files && \
    npm install --legacy-peer-deps && \
    npm install webpack@latest --legacy-peer-deps && \
    npm update --legacy-peer-deps && \
    npm install util --legacy-peer-deps && \
    npm i --save-dev process --legacy-peer-deps && \
    npm run build --legacy-peer-deps && \
    conda deactivate" && \
    cd /home/ffbo/ffbo/ffbo.neuronlp && \
    git checkout hemibrain && \
    rm -rf /home/ffbo/.cache

ARG FLYBRAINLAB_DOCKER_VER=unknown

# RUN /bin/bash -c ". $HOME/miniconda/etc/profile.d/conda.sh && \
#     conda activate crossbar && \
#     conda deactivate && \
#     conda activate ffbo && \
#     cd /home/ffbo/ffbo/quepy && \
#     git pull && python -m pip install -e . && \
#     cd /home/ffbo/ffbo/ffbo.nlp_component && \
#     git pull && python -m pip install -e . && \
#     cd /home/ffbo/ffbo/neurokernel && \
#     git pull && python -m pip install -e . && \
#     cd /home/ffbo/ffbo/neurodriver && \
#     git pull && python -m pip install -e . && \
#     cd /home/ffbo/ffbo/ffbo.neurokernel_component && \
#     git pull && python -m pip install -e . && \
#     cd /home/ffbo/ffbo/Neuroballad && \
#     git pull && python -m pip install -e . && \
#     cd /home/ffbo/ffbo/neu3d && \
#     git pull && jlpm run build && \
#     cd /home/ffbo/ffbo/NeuroMynerva && \
#     jlpm run build && \
#     conda deactivate && \
#     cd /home/ffbo/ffbo/Tutorials && git pull" && \
#     rm -rf /home/ffbo/.cache && \
#     rm -rf /tmp/*.*

RUN mkdir -p /home/ffbo/.ffbo/config && \
    cp /home/ffbo/ffbo/ffbo.processor/config.ini /home/ffbo/.ffbo/config/ && \
    sed -i -e "11,15d; 26,29d; s+8081+8081+g" /home/ffbo/.ffbo/config/config.ini && \
    git clone https://github.com/FlyBrainLab/run_scripts.git && \
    cp -r run_scripts/flybrainlab /home/ffbo/ffbo/bin && \
    cd /home/ffbo/ffbo/bin && \
    sed -i -e "s+{FFBO_DIR}+/home/ffbo/ffbo+g; s+{FFBO_ENV}+ffbo+g; s+{CROSSBAR_ENV}+crossbar+g; s+\$(conda info --base)+/home/ffbo/miniconda+g" run_processor.sh && \
    sed -i -e "s+{FFBO_DIR}+/home/ffbo/ffbo+g; s+{FFBO_ENV}+ffbo+g; s+\$(conda info --base)+/home/ffbo/miniconda+g" run_nlp.sh && \
    sed -i -e "s+{FFBO_DIR}+/home/ffbo/ffbo+g; s+{FFBO_ENV}+ffbo+g; s+\$(conda info --base)+/home/ffbo/miniconda+g" run_neuroarch.sh && \
    sed -i -e "s+{FFBO_DIR}+/home/ffbo/ffbo+g; s+{FFBO_ENV}+ffbo+g; s+\$(conda info --base)+/home/ffbo/miniconda+g" run_neurokernel.sh && \
    sed -i -e "s+{ORIENTDB_ROOT}+/home/ffbo/orientdb+g" run_database.sh && \
    sed -i -e "s+{FFBO_DIR}+/home/ffbo/ffbo+g; s+{FFBO_ENV}+ffbo+g; s+\$(conda info --base)+/home/ffbo/miniconda+g" run_fbl.sh && \
    sed -i -e "s+{FFBO_DIR}+/home/ffbo/ffbo+g; s+{ORIENTDB_ROOT}+/home/ffbo/orientdb+g" start.sh && \
    sed -i -e "s+{ORIENTDB_ROOT}+/home/ffbo/orientdb+g;" shutdown.sh && \
    sed -i -e "s+{FFBO_DIR}+/home/ffbo/ffbo+g; s+{FFBO_ENV}+ffbo+g; s+{CROSSBAR_ENV}+crossbar+g; s+\$(conda info --base)+/home/ffbo/miniconda+g" update_local_repo.sh && \
    mv update_local_repo.sh update.sh && \
    rm -rf /home/ffbo/run_scripts && \
    /home/ffbo/ffbo/bin/download_drosobot_data.sh /home/ffbo/ffbo/ffbo.nlp_component/nlp_component/data && \
    mkdir -p /home/ffbo/.jupyter/lab/user-settings/@flybrainlab/neuromynerva && \
    wget https://raw.githubusercontent.com/FlyBrainLab/NeuroMynerva/master/schema/plugin.json.local -O /home/ffbo/.jupyter/lab/user-settings/@flybrainlab/neuromynerva/plugin.jupyterlab-settings && \
    echo "export ORIENTDB_ROOT_PASSWORD=root" | tee -a ~/.bashrc && \
    echo 'export ORIENTDB_OPTS_MEMORY="-Xms1G -Xmx8G" # increase or decrease Xmx to fit the memory size of your machine' | tee -a ~/.bashrc && \
    echo "export ORIENTDB_SETTINGS=-Dstorage.diskCache.bufferSize=10240 # the amount of memory in MB used for disk cache. This plus Xmx above must be smaller than the total size of memory on your machine." | tee -a ~/.bashrc && \
    echo "export PATH=/usr/local/bin:/usr/local/cuda/bin:/usr/bin:/usr/sbin:$PATH" | tee -a ~/.bashrc && \
    echo "export LD_LIBRARY_PATH=/usr/local/lib:/usr/local/cuda/lib64:/usr/lib:/usr/lib/x86_64-linux-gnu:$LD_LIBRARY_PATH" | tee -a ~/.bashrc && \
    echo "export OMPI_MCA_opal_cuda_support=true" | tee -a ~/.bashrc

ENV ORIENTDB_ROOT_PASSWORD=root \
    ORIENTDB_OPTS_MEMORY="-Xms1G -Xmx8G" \
    ORIENTDB_SETTINGS=-Dstorage.diskCache.bufferSize=10240

SHELL ["/bin/bash", "-c"]
CMD /home/ffbo/ffbo/bin/download_datasets.sh /home/ffbo/orientdb && /home/ffbo/ffbo/bin/start.sh
