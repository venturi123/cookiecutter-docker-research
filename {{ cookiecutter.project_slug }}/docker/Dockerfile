FROM nvcr.io/nvidia/pytorch:{{ cookiecutter.nvidia_docker_tag }}

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    sudo tmux htop pipx bash-completion && \
    pipx ensurepath && \
    rm -rf /var/lib/apt/lists/

ARG UID
RUN useradd docker -l -u $UID -s /bin/bash -m && \
    echo 'docker ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers
USER docker

COPY docker/.bash_aliases docker/.tmux.conf docker/.bashrc docker/requirements.txt /home/docker
COPY docker/htoprc /home/docker/.config/htop/htoprc

RUN pip3 install --upgrade pip
RUN pip install --no-cache-dir -r /home/docker/requirements.txt

ENV PATH=$PATH:/home/docker/.local/bin
ENV PYTHONPATH=/home/docker/{{ cookiecutter.project_slug }}
WORKDIR /home/docker/{{ cookiecutter.project_slug }}
