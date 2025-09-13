export PYTHONUNBUFFERED=1

echo "**** Setting the timezone based on the TIME_ZONE environment variable. If not set, it defaults to Etc/UTC. ****"
export TZ=${TIME_ZONE:-"Etc/UTC"}
echo "**** Timezone set to $TZ ****"
echo "$TZ" | sudo tee /etc/timezone > /dev/null
sudo ln -sf "/usr/share/zoneinfo/$TZ" /etc/localtime
sudo dpkg-reconfigure -f noninteractive tzdata

echo "python $ARG_PYTHON_VERSION"
echo "torch $ARG_TORCH_VERSION"
echo "cuda $ARG_CUDA_VERSION"

setup_miniconda() {
    cd /workspace
    curl -LO https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
    chmod a+x Miniconda3-latest-Linux-x86_64.sh
    ./Miniconda3-latest-Linux-x86_64.sh -b -p /workspace/miniconda3
    if [[ ! "$PATH" == *"/workspace/miniconda3/bin"* ]]; then
        export PATH="/workspace/miniconda3/bin:$PATH"
    fi
    conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/main
    conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/r
    conda create -n comfy python=$ARG_PYTHON_VERSION -y
    source /workspace/miniconda3/bin/activate comfy
    pip install --no-cache-dir -U \
        wheel \
        numpy scipy
}

if [ -d "/workspace" ]; then
    if [ ! -d "/workspace/miniconda3" ]; then
        echo "*** installing miniconda ***"
        setup_miniconda
    fi    
fi