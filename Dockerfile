# Set the base image
ARG BASE_IMAGE
FROM ${BASE_IMAGE}

# Set the shell and enable pipefail for better error handling
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Set basic environment variables
ARG PYTHON_VERSION
ARG TORCH_VERSION
ARG CUDA_VERSION

# Set basic environment variables
ENV SHELL=/bin/bash 
ENV PYTHONUNBUFFERED=True 
ENV DEBIAN_FRONTEND=noninteractive

# Set TZ and Locale
ENV TZ=Etc/UTC

# Set working directory
WORKDIR /

EXPOSE 22 3000 5000 8080

# NGINX Proxy
COPY proxy/nginx.conf /etc/nginx/nginx.conf
COPY proxy/snippets /etc/nginx/snippets
COPY proxy/readme.html /usr/share/nginx/html/readme.html

# Copy the README.md
COPY README.md /usr/share/nginx/html/README.md

# Copy setup files
COPY custom_nodes.txt /setup/custom_nodes.txt

# app
COPY app /setup/app

# Start Scripts
COPY --chmod=755 scripts/start.sh /setup/
COPY --chmod=755 scripts/pre.sh /setup/

# Welcome Message
COPY logo/am05mhz.txt /etc/am05mhz.txt
RUN echo 'cat /etc/am05mhz.txt' >> /root/.bashrc
RUN echo 'echo -e "\nFor detailed documentation and guides, please visit:\n\033[1;34mhttps://docs.runpod.io/\033[0m and \033[1;34mhttps://blog.runpod.io/\033[0m\n\n"' >> /root/.bashrc

# Remove existing SSH host keys
RUN rm -f /etc/ssh/ssh_host_*

# Set entrypoint to the start script
CMD ["/setup/start.sh"]
