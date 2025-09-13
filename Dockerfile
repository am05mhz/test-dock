# Set the base image
ARG BASE_IMAGE
FROM ${BASE_IMAGE}

# Set the shell and enable pipefail for better error handling
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Set basic environment variables
ARG PYTHON_VERSION
ARG TORCH_VERSION
ARG CUDA_VERSION

ENV ARG_PYTHON_VERSION=${PYTHON_VERSION}
ENV ARG_TORCH_VERSION=${TORCH_VERSION}
ENV ARG_CUDA_VERSION=${CUDA_VERSION}

# Set basic environment variables
ENV SHELL=/bin/bash 
ENV PYTHONUNBUFFERED=True 
ENV DEBIAN_FRONTEND=noninteractive

# Set TZ and Locale
ENV TZ=Etc/UTC

# Set working directory
WORKDIR /

# Update and upgrade
RUN apt-get update --yes && \
    apt-get upgrade --yes

RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen

# Install essential packages
RUN apt-get install --yes --no-install-recommends \
        git wget curl bash nginx-light rsync sudo binutils ffmpeg lshw nano tzdata file build-essential cmake nvtop \
        libgl1 libglib2.0-0 clang libomp-dev ninja-build \
        openssh-server ca-certificates && \
    apt-get autoremove -y && apt-get clean && rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*

EXPOSE 22 3000 5000 8080

# NGINX Proxy
COPY proxy/nginx.conf /etc/nginx/nginx.conf
COPY proxy/snippets /etc/nginx/snippets
COPY proxy/readme.html /usr/share/nginx/html/readme.html

# Copy the README.md
COPY README.md /usr/share/nginx/html/README.md

RUN mkdir /setup

# app
COPY app /setup/app

# Start Scripts
COPY --chmod=755 scripts/start.sh /setup/
COPY --chmod=755 scripts/pre.sh /setup/

# Welcome Message
COPY logo/am05mhz.txt /etc/am05mhz.txt
RUN echo 'cat /etc/am05mhz.txt' >> /root/.bashrc

# Remove existing SSH host keys
RUN rm -f /etc/ssh/ssh_host_*

# Set entrypoint to the start script
CMD ["/setup/start.sh"]
