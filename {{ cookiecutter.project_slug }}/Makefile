.PHONY: on-host on-docker clean clean-model clean-pyc docs help init init-docker create-container start-container jupyter test lint profile \
        clean-data clean-docker clean-container clean-image sync-from-source sync-to-source init-docker-no-cache backup \
        attach-container launch-container archive reproduce verify-cuda clean-container-force clean-docker-cache destroying format
.DEFAULT_GOAL := help

###########################################################################################################
## SCRIPTS
###########################################################################################################

define PRINT_HELP_PYSCRIPT
import os, re, sys

if os.environ['TARGET']:
    target = os.environ['TARGET']
    is_in_target = False
    for line in sys.stdin:
        match = re.match(r'^(?P<target>{}):(?P<dependencies>.*)?## (?P<description>.*)$$'.format(target).format(target), line)
        if match:
            print("target: %-20s" % (match.group("target")))
            if "dependencies" in match.groupdict().keys():
                print("dependencies: %-20s" % (match.group("dependencies")))
            if "description" in match.groupdict().keys():
                print("description: %-20s" % (match.group("description")))
            is_in_target = True
        elif is_in_target == True:
            match = re.match(r'^\t(.+)', line)
            if match:
                command = match.groups()
                print("command: %s" % (command))
            else:
                is_in_target = False
else:
    for line in sys.stdin:
        match = re.match(r'^([a-zA-Z_-]+):.*?## (.*)$$', line)
        if match:
            target, help = match.groups()
            print("%-20s %s" % (target, help))
endef

define START_DOCKER_CONTAINER
if [ `$(DOCKER) inspect -f {% raw -%}{{.State.Running}}{%- endraw %} $(CONTAINER_NAME)` = "false" ] ; then
        $(DOCKER) start $(CONTAINER_NAME)
fi
endef

###########################################################################################################
## VARIABLES
###########################################################################################################

export DOCKER=docker
export TARGET=
export PWD=`pwd`
export PRINT_HELP_PYSCRIPT
export START_DOCKER_CONTAINER
export PYTHONPATH=$PYTHONPATH:$(PWD)
export PROJECT_NAME={{ cookiecutter.project_slug }}
export DOCKERFILE=docker/Dockerfile
export IMAGE_NAME=$(PROJECT_NAME)-image
export CONTAINER_NAME=$(PROJECT_NAME)-container
export DATA_SOURCE={{ cookiecutter.data_source }}
export JUPYTER_HOST_PORT={{ cookiecutter.jupyter_host_port }}
export JUPYTER_CONTAINER_PORT=8888
export PYTHON=python
export DATE=$(shell date +%Y%m%d%H%M%S)

###########################################################################################################
## ADD TARGETS SPECIFIC TO "{{ cookiecutter.project_name }}"
###########################################################################################################


###########################################################################################################
## GENERAL TARGETS
###########################################################################################################

help: ## show this message
	@$(PYTHON) -c "$$PRINT_HELP_PYSCRIPT" < $(MAKEFILE_LIST)

# check if host
on-host:
	@if [ "$$(whoami)" = "docker" ]; then \
		printf "\033[0;31mError: This script should be run on the host, not inside a Docker container.\033[0m\n"; \
		exit 1; \
	fi

# check if docker
on-docker:
	@if ! [ "$$(whoami)" = "docker" ]; then \
		printf "\033[0;31mError: This script should be run inside a Docker container, not on the host.\033[0m\n"; \
		exit 1; \
	fi

init: init-docker sync-from-source ## initialize repository for traning

sync-from-source: ## download data data source to local envrionment
{%- if cookiecutter.data_source_type == 's3' %}
	-aws s3 sync $(DATA_SOURCE) ./data/
{%- elif cookiecutter.data_source_type == 'nfs' %}
	cp -r $(DATA_SOURCE)/* ./data/
{%- elif cookiecutter.data_source_type == 'url' %}
	wget $(DATA_SOURCE) -P ./data/
{%- elif cookiecutter.data_source_type == 'manual' %}

{% endif %}

sync-to-source: ## sync local data to data source
{%- if cookiecutter.data_source_type == 's3' %}
	-aws s3 sync ./data/ $(DATA_SOURCE)
{%- elif cookiecutter.data_source_type == 'nfs' %}
	cp -r ./data/* $(DATA_SOURCE)/
{%- elif cookiecutter.data_source_type == 'url' %}
	echo "no sync target for url data source..."
{%- elif cookiecutter.data_source_type == 'manual' %}
	echo "external data will not be downloaded/copied within this project folder,"
	echo "mount data folder when create docker container with -v flag."
{% endif %}

init-docker: on-host ## initialize docker image
	$(DOCKER) build -t $(IMAGE_NAME) -f $(DOCKERFILE) --build-arg UID=$(shell id -u) .

init-docker-no-cache: on-host ## initialize docker image without cache
	$(DOCKER) build --no-cache -t $(IMAGE_NAME) -f $(OCKERFILE) --build-arg UID=$(shell id -u) .

# Recommanded, first up a container and keep it running (important for VS Code), then fork a new connect session. No interruption between them.
create-container: on-host ## create docker container
	$(DOCKER) run -d --gpus all --ipc=host --pid=host -p $(JUPYTER_HOST_PORT):$(JUPYTER_CONTAINER_PORT) -v "${PWD}:/home/docker/${PROJECT_NAME}" -v "${HOME}/.ssh:/home/docker/.ssh" --name $(CONTAINER_NAME) $(IMAGE_NAME) tail -f /dev/null
attach-container: on-host ## attach docker container
	@echo "$$START_DOCKER_CONTAINER" | $(SHELL)
	@echo "Launched $(CONTAINER_NAME)..."
	$(DOCKER) exec -it $(CONTAINER_NAME) /bin/bash

# Not recommanded, start-container will connect to the exist launch-container session, not new a terminal
launch-container: on-host ## launch docker container
	$(DOCKER) run -it --gpus all --ipc=host --pid=host -p $(JUPYTER_HOST_PORT):$(JUPYTER_CONTAINER_PORT) -v "${PWD}:/home/docker/${PROJECT_NAME}" -v "${HOME}/.ssh:/home/docker/.ssh" --name $(CONTAINER_NAME) $(IMAGE_NAME)
start-container: on-host ## start docker container
	@echo "$$START_DOCKER_CONTAINER" | $(SHELL)
	@echo "Launched $(CONTAINER_NAME)..."
	$(DOCKER) attach $(CONTAINER_NAME)

backup: ## fast backup to github repository
	@bash docker/backup.sh

archive: on-host ## archive all the data/environment to one file with SHA256
	@command -v zstd >/dev/null 2>&1 || { echo -e >&2 "\033[31mzstd is required but it's not installed.\033[0m\nPlease install zstd library first using:\n\033[32msudo apt install zstd\033[0m"; exit 1; }
	@$(DOCKER) commit $(CONTAINER_NAME) $(IMAGE_NAME)-$(DATE) >/dev/null 2>&1
	@$(DOCKER) save -o $(IMAGE_NAME)-$(DATE).tar $(IMAGE_NAME)-$(DATE) >/dev/null 2>&1
	@$(DOCKER) rmi $(IMAGE_NAME)-$(DATE) >/dev/null 2>&1
	@echo "$(CONTAINER_NAME)-$(DATE) has been packaged successfully!"
	
	@cd .. >/dev/null 2>&1 && \
	tar -I zstd -cvf $(PROJECT_NAME).tar.zst $(PROJECT_NAME)  >/dev/null 2>&1 && \
	sha256sum $(PROJECT_NAME).tar.zst > $(PROJECT_NAME).tar.zst.sha256
	@echo "$(PROJECT_NAME) has been archived successfully!"
reproduce: on-host ## reload the env from .tar file
	@reproduce_tar=$(shell ls -t $(IMAGE_NAME)-*.tar | head -n 1) && \
	if [ -z "$$reproduce_tar" ]; then \
		echo "No tar file found."; \
		exit 1; \
	else \
		reproduce_image_name=$$(echo $$reproduce_tar | sed 's/\.tar$$//') && \
		reproduce_container_name=$$(echo $$reproduce_image_name | sed 's/image/container/') && \
		$(DOCKER) load -i $$reproduce_tar && \
		$(DOCKER) run -d --gpus all --ipc=host --pid=host -p $(JUPYTER_HOST_PORT):$(JUPYTER_CONTAINER_PORT) -v "$${PWD}:/home/docker/${PROJECT_NAME}" --name $$reproduce_container_name $$reproduce_image_name && \
		echo "Enter the container using the command:\n\033[32m$(DOCKER) exec -it $$reproduce_container_name /bin/bash\033[0m"; \
	fi

jupyter: on-docker ## start Jupyter Notebook server
	jupyter lab --ip=0.0.0.0 --port=${JUPYTER_CONTAINER_PORT}

test: on-docker ## run test cases in tests directory
	$(PYTHON) -m unittest discover
	
verify-cuda: on-docker ## check if cuda installed correctly
	$(PYTHON) docker/verify_cuda.py

lint: ## linter
	ruff check --fix

profile: on-host ## show profile of the project
	@echo "CONTAINER_NAME: $(CONTAINER_NAME)"
	@echo "IMAGE_NAME: $(IMAGE_NAME)"
	@echo "JUPYTER_PORT: `$(DOCKER) port $(CONTAINER_NAME)`"
	@echo "DATA_SOURE: $(DATA_SOURCE)"

clean: clean-model clean-pyc clean-docker ## remove all artifacts

clean-model: ## remove model artifacts
	rm -fr model/*

clean-pyc: ## remove python file artifacts
	find . -name '*.pyc' -exec rm -f {} +
	find . -name '*.pyo' -exec rm -f {} +
	find . -name '*~' -exec rm -f {} +
	find . -name '__pycache__' -exec rm -fr {} +

distclean: clean clean-data ## remove all the reproducible resources including Docker images

clean-data: ## remove files under data
	rm -fr data/*

clean-docker: clean-container-force clean-image ## remove Docker image and container

clean-container: ## remove Docker container
	-$(DOCKER) rm $(CONTAINER_NAME)
	
clean-container-force: ## force remove Docker container
	-$(DOCKER) rm -f $(CONTAINER_NAME)

clean-image: ## remove Docker image
	-$(DOCKER) image rm $(IMAGE_NAME)
	
clean-docker-cache: # DANGER! YOU SHOULD KNOW WHAT WILL HAPPEN BEFORE RUN
	-$(DOCKER) system prune -a
	
destroying: on-host clean-docker  ## DANGER! YOU SHOULD KNOW WHAT WILL HAPPEN BEFORE RUN
	-cd .. && rm -rf $(PROJECT_NAME)

format:
	-ruff format
