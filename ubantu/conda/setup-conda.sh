#!/bin/bash
sudo apt install python3-pip
pip3 install virtualenv
mkdir $conda
cp ./* $conda/
python3 -m virtualenv $conda/conda-env
sudo chmod -R 777 $conda.sh
source $conda/aconda.sh
which python
pip install -r environment.txt
deactivate
echo "alias aconda=\"source $conda/aconda.sh\"" >> ~/.bashrc
echo "alias slab=\"source $conda/slab.sh\"" >> ~/.bashrc
source ~/.bashrc
