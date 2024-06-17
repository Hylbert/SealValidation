#!/bin/bash

set -e
 
 PATH_PROJECT="TCC"
 PATH_BASE="$HOME/Documentos/"

# Função para atualizar o sistema e instalar dependências
install_dependencies() {

  sudo apt-get install -y \
    python3-pip \
    libopencv-dev \
    awscli

    #INSTALAR cuda-toolkit-----
    echo "Install Cuda Tool Kit"
    #Base Installer
    wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-ubuntu2204.pin
    sudo mv cuda-ubuntu2204.pin /etc/apt/preferences.d/cuda-repository-pin-600
    wget https://developer.download.nvidia.com/compute/cuda/12.5.0/local_installers/cuda-repo-ubuntu2204-12-5-local_12.5.0-555.42.02-1_amd64.deb
    sudo dpkg -i cuda-repo-ubuntu2204-12-5-local_12.5.0-555.42.02-1_amd64.deb
    sudo cp /var/cuda-repo-ubuntu2204-12-5-local/cuda-*-keyring.gpg /usr/share/keyrings/
    sudo apt-get update
    sudo apt-get install cuda-toolkit-12-5 libcublas-12-5 libcublas-dev-12-5
    export LD_LIBRARY_PATH=/usr/local/cuda-12.5/lib64:$LD_LIBRARY_PATH
    export PATH=/usr/local/cuda-12.5/bin:$
    echo 'export LD_LIBRARY_PATH=/usr/local/cuda-12.5/lib64:$LD_LIBRARY_PATH' >> ~/.bashrc
    echo 'export PATH=/usr/local/cuda-12.5/bin:$PATH' >> ~/.bashrc
    source ~/.bashrc



    #INSTALAR cuDNN
    echo "Install cuDNN"
    #Base Installer
    wget https://developer.download.nvidia.com/compute/cudnn/9.2.0/local_installers/cudnn-local-repo-ubuntu2204-9.2.0_1.0-1_amd64.deb
    sudo dpkg -i cudnn-local-repo-ubuntu2204-9.2.0_1.0-1_amd64.deb
    sudo cp /var/cudnn-local-repo-ubuntu2204-9.2.0/cudnn-*-keyring.gpg /usr/share/keyrings/
    sudo apt-get update
    sudo apt-get -y install cudnn


    pip3 install tensorflow
}

find_folder(){
    cd $PATH_BASE
    if [ ! -d $PATH_PROJECT ]; then
        mkdir $PATH_BASE/$PATH_PROJECT
    fi
    cd $PATH_PROJECT
}

OIDv4_ToolKit_prepare(){
    if [ ! -d OIDv4_ToolKit ]; then
        git clone https://github.com/EscVM/OIDv4_ToolKit.git
    fi
    cd OIDv4_ToolKit
    pip3 install -r requirements.txt
}

train_test_images(){
    python3 main.py downloader --classes Box Coffee_cup Computer_mouse --type_csv train --limit 500 --multiclasses 1 
    python3 main.py downloader --classes Box Coffee_cup Computer_mouse --type_csv test --limit 100 --multiclasses 1
}
notes_prepare(){
    cd $PATH_BASE/$PATH_PROJECT/OIDv4_ToolKit
    echo -e "Box\nCoffee cup\nComputer mouse" > classes.txt
    if [ ! -d TreinamentoCustomizadoYOLO ]; then
        git clone -n https://github.com/Hemilibeatriz/TreinamentoCustomizadoYOLO.git
    fi
    cd TreinamentoCustomizadoYOLO/
    git checkout HEAD converter_anotacoes.py
    mv converter_anotacoes.py ../
    cd ..
    python3 converter_anotacoes.py
}

darknet_setup(){
    cd $PATH_BASE/$PATH_PROJECT
    if [ ! -d darknet ]; then
        git clone https://github.com/AlexeyAB/darknet
    fi
    cd darknet/
    # Caminho do Makefile
    MAKEFILE_PATH="./Makefile"

    # Modificando as linhas no Makefile
    sed -i 's/^GPU=.*/GPU=1/' "$MAKEFILE_PATH"
    sed -i 's/^CUDNN=.*/CUDNN=1/' "$MAKEFILE_PATH"
    sed -i 's/^OPENCV=.*/OPENCV=1/' "$MAKEFILE_PATH"

    echo "Linhas substituídas no Makefile com sucesso."

    make -j10
}

custom_cfg(){
    cp cfg/yolov4.cfg ../yolov4_tcc.cfg
    touch obj.names
    echo -e "Box\nCoffee cup\nComputer mouse" > obj.names
    touch obj.data

    echo -e "classes= 3\ntrain  = data/train.txt\nvalid  = data/test.txt\nnames = data/obj.names\nbackup = darknet/backup" > obj.data


    cp obj.* ../
}

make_txt(){
    cd $PATH_BASE/$PATH_PROJECT/OIDv4_ToolKit
    if [ ! -d data ]; then
        mkdir data
    fi
    cp -r OID/Dataset/train/Box_Coffee\ cup_Computer\ mouse ./data/obj/
    cp -r OID/Dataset/test/Box_Coffee\ cup_Computer\ mouse ./data/valid/
}

generate_train_test(){
    cd OIDv4_ToolKit/TreinamentoCustomizadoYOLO/
    git checkout HEAD gera_train.py
    git checkout HEAD gera_test.py
    mv gera_t* ../

    cd ../
    python3 gera_train.py
    python3 gera_test.py
    cp data/train.txt ../
    cp data/test.txt ../
}

prepare_YOLO(){
    cd $PATH_BASE/$PATH_PROJECT/darknet
    cp ../yolov4_tcc.cfg ./cfg/
    cp ../obj.* ./data/
    cp ../t* ./data/
    cp -r ../OIDv4_ToolKit/data/obj ./data/
    cp -r ../OIDv4_ToolKit/data/valid ./data/

    wget https://github.com/AlexeyAB/darknet/releases/download/darknet_yolo_v3_optimal/yolov4.conv.137
}
# install_dependencies
# find_folder
# OIDv4_ToolKit_prepare
# train_test_images
# notes_prepare
# darknet_setup
# custom_cfg
# make_txt
generate_train_test
# prepare_YOLO

