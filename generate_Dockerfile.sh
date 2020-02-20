#!/usr/bin/env bash
cd $(cd -P -- "$(dirname -- "$0")" && pwd -P)

# Set the path of the generated Dockerfile
export DOCKERFILE=".build/Dockerfile"
export STACKS_DIR=".build/docker-stacks"


# Clone if docker-stacks doesn't exist, and pull.
ls $STACKS_DIR/README.md  > /dev/null 2>&1  || (echo "Docker-stacks was not found, cloning repository" \
 && git clone https://github.com/jupyter/docker-stacks.git $STACKS_DIR)
git pull -f $STACKS_DIR

# Write the contents into the DOCKERFILE and start with the header
cat src/Dockerfile.header > $DOCKERFILE
cp src/jupyter_notebook_config.json .build/

echo "
############################################################################
#################### Dependency: jupyter/base-image ########################
############################################################################
" >> $DOCKERFILE
cat $STACKS_DIR/base-notebook/Dockerfile | grep -v BASE_CONTAINER >> $DOCKERFILE
cp $STACKS_DIR/base-notebook/fix-permissions .build/
cp $STACKS_DIR/base-notebook/jupyter_notebook_config.py .build/
cp $STACKS_DIR/base-notebook/start.sh .build/
cp $STACKS_DIR/base-notebook/start-notebook.sh .build/
cp $STACKS_DIR/base-notebook/start-singleuser.sh .build/

echo "
############################################################################
################# Dependency: jupyter/minimal-notebook #####################
############################################################################
" >> $DOCKERFILE
cat $STACKS_DIR/minimal-notebook/Dockerfile | grep -v BASE_CONTAINER >> $DOCKERFILE

echo "
############################################################################
################# Dependency: jupyter/scipy-notebook #######################
############################################################################
" >> $DOCKERFILE
cat $STACKS_DIR/scipy-notebook/Dockerfile | grep -v BASE_CONTAINER >> $DOCKERFILE

echo "
############################################################################
################ Dependency: jupyter/datascience-notebook ##################
############################################################################
" >> $DOCKERFILE
cat $STACKS_DIR/datascience-notebook/Dockerfile | grep -v BASE_CONTAINER >> $DOCKERFILE

echo "
############################################################################
################ Dependency: jupyter/tensorflow-notebook ###################
############################################################################
" >> $DOCKERFILE
cat $STACKS_DIR/tensorflow-notebook/Dockerfile | grep -v BASE_CONTAINER >> $DOCKERFILE

# Note that the following step also installs the cudatoolkit, which is
# essential to access the GPU.
echo "
############################################################################
########################## Dependency: pytorch #############################
############################################################################
" >> $DOCKERFILE
cat src/Dockerfile.pytorch >> $DOCKERFILE


echo "
############################################################################
############################ Useful packages ###############################
############################################################################
" >> $DOCKERFILE
cat src/Dockerfile.usefulpackages >> $DOCKERFILE

cp $DOCKERFILE Dockerfile
echo "GPU Dockerfile was generated sucessfully in file $(pwd)/${DOCKERFILE} and copied to ./Dockerfile"
echo "Run 'bash run_Dockerfile.sh -p [PORT]' to start the GPU-based Juyterlab instance."
