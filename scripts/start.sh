#!/bin/bash
set -e  # Exit the script if any statement returns a non-true return value

# ---------------------------------------------------------------------------- #
#                          Function Definitions                                #
# ---------------------------------------------------------------------------- #

# Setup ssh
setup_ssh() {
    if [[ $PUBLIC_KEY ]]; then
        echo "Setting up SSH..."
        mkdir -p ~/.ssh
        echo "$PUBLIC_KEY" >> ~/.ssh/authorized_keys
        chmod 700 -R ~/.ssh

        ssh-keygen -A       # regenerate new keys
        service ssh start
    fi
}

# Start nginx service
start_nginx() {
    echo "Starting Nginx service..."
    service nginx start
}

# Execute script if exists
execute_script() {
    local script_path=$1
    local script_msg=$2
    if [[ -f ${script_path} ]]; then
        echo "${script_msg}"
        bash ${script_path}
    fi
}

start_app() {
    echo "Starting app..."
    if [[ ! "$PATH" == *"/workspace/miniconda3/bin"* ]]; then
        export PATH="/workspace/miniconda3/bin:$PATH"
    fi
    source /workspace/miniconda3/bin/activate comfy
    cd /workspace/app
    which pip
    which python
}

# ---------------------------------------------------------------------------- #
#                               Main Program                                   #
# ---------------------------------------------------------------------------- #

setup_ssh
start_nginx

execute_script "/setup/pre.sh" "Running pre script..."

start_app

echo "Start script(s) finished, pod is ready to use."

sleep infinity
