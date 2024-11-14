.DEFAULT_GOAL := help

###########################################################################################################
## VARIABLES
###########################################################################################################

export DOCKER=docker
export PWD=$(shell pwd)
export HOST_UID=$(shell id -u)
export HOST_GID=$(shell id -g)
export PROJECT_NAME={{ cookiecutter.project_slug }}
export DATA_SOURCE={{ cookiecutter.data_source }}
export JUPYTER_HOST_PORT={{ cookiecutter.jupyter_host_port }}
export JUPYTER_CONTAINER_PORT=8888
export IMAGE_NAME=$(PROJECT_NAME)-image
export CONTAINER_NAME=$(PROJECT_NAME)-container
export DATE=$(shell date +%Y%m%d%H%M%S)
export PYTHON=python

###########################################################################################################
## HELPERS
###########################################################################################################

.PHONY: check-docker-installed
check-docker-installed: ## Check if Docker is installed
	@command -v docker >/dev/null 2>&1 || { echo "Docker is required but not installed."; exit 1; }

.PHONY: check-is-host
check-is-host: ## Verify that this script is running on the host, not in Docker
	@if [ "$$(whoami)" = "docker" ]; then \
		echo "Error: This script should be run on the host, not inside a Docker container."; \
		exit 1; \
	fi

.PHONY: check-is-docker
check-is-docker: ## Verify that this script is running inside a Docker container
	@if ! [ "$$(whoami)" = "docker" ]; then \
		echo "Error: This script should be run inside a Docker container, not on the host."; \
		exit 1; \
	fi

###########################################################################################################
## GENERAL TARGETS
###########################################################################################################

.PHONY: help
help: ## Show help message for each target
	@awk 'BEGIN {FS = ":.*?## "}; /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.PHONY: on-host
on-host: check-is-host ## Ensure the script is running on the host machine

.PHONY: on-docker
on-docker: check-is-docker ## Ensure the script is running inside a Docker container

.PHONY: init
init: init-docker sync-from-source ## Initialize the repository for training by setting up Docker and syncing data

.PHONY: sync-from-source
sync-from-source: ## Download data from the specified data source to the local environment
	{% if cookiecutter.data_source_type == 's3' %}
		@aws s3 sync $(DATA_SOURCE) ./data/
	{% elif cookiecutter.data_source_type == 'nfs' %}
		@cp -r $(DATA_SOURCE)/* ./data/
	{% elif cookiecutter.data_source_type == 'url' %}
		@wget $(DATA_SOURCE) -P ./data/
	{% elif cookiecutter.data_source_type == 'manual' %}
		@echo "External data should be mounted manually."
	{% endif %}

.PHONY: sync-to-source
sync-to-source: ## Sync local data to the specified data source
	{% if cookiecutter.data_source_type == 's3' %}
		@aws s3 sync ./data/ $(DATA_SOURCE)
	{% elif cookiecutter.data_source_type == 'nfs' %}
		@cp -r ./data/* $(DATA_SOURCE)/
	{% elif cookiecutter.data_source_type == 'url' %}
		@echo "No sync target for URL data source."
	{% elif cookiecutter.data_source_type == 'manual' %}
		@echo "Data will not be synced. Please sync manually if needed."
	{% endif %}

.PHONY: init-docker
init-docker: on-host check-docker-installed ## Build the Docker image for the project
	@$(DOCKER) build -t $(IMAGE_NAME) -f docker/Dockerfile \
		--build-arg USER_UID=$(HOST_UID) \
		--build-arg USER_GID=$(HOST_GID) .

.PHONY: init-docker-no-cache
init-docker-no-cache: on-host check-docker-installed ## Build the Docker image without cache
	@$(DOCKER) build --no-cache -t $(IMAGE_NAME) -f docker/Dockerfile \
		--build-arg USER_UID=$(HOST_UID) \
		--build-arg USER_GID=$(HOST_GID) .

.PHONY: create-container
create-container: on-host check-docker-installed ## Create and start a detached Docker container
	@$(DOCKER) run -d --gpus all --ipc=host --pid=host --runtime=nvidia \
		-p $(JUPYTER_HOST_PORT):$(JUPYTER_CONTAINER_PORT) \
		-v "${PWD}:/home/docker/${PROJECT_NAME}" \
		-v "${HOME}/.ssh:/home/docker/.ssh" \
		--name $(CONTAINER_NAME) \
		$(IMAGE_NAME) tail -f /dev/null

.PHONY: attach-container
attach-container: on-host ## Attach to a running Docker container
	@$(DOCKER) start $(CONTAINER_NAME) || true
	@$(DOCKER) exec -it $(CONTAINER_NAME) /bin/bash

.PHONY: backup
backup: ## Fast backup to GitHub repository
	@bash docker/backup.sh

.PHONY: archive
archive: on-host ## Archive all data/environment into one .tar.gz file with SHA256
	@command -v gzip >/dev/null 2>&1 || { \
		echo -e "\033[31mgzip is required but not installed.\033[0m\nPlease install gzip."; \
		exit 1; \
	}
	@$(DOCKER) commit $(CONTAINER_NAME) $(IMAGE_NAME)-$(DATE) >/dev/null 2>&1
	@$(DOCKER) save -o $(IMAGE_NAME)-$(DATE).tar $(IMAGE_NAME)-$(DATE) >/dev/null 2>&1
	@$(DOCKER) rmi $(IMAGE_NAME)-$(DATE) >/dev/null 2>&1
	@echo "$(CONTAINER_NAME)-$(DATE) has been packaged successfully!"
	@cd .. && \
	@tar -czf $(PROJECT_NAME).tar.gz $(PROJECT_NAME) && sha256sum $(PROJECT_NAME).tar.gz > $(PROJECT_NAME).tar.gz.sha256
	@echo "$(PROJECT_NAME) has been archived successfully!"
	
.PHONY: reproduce
reproduce: on-host ## Reload the environment from a .tar file
	@reproduce_tar=$(shell ls -t $(PROJECT_NAME)-*.tar | head -n 1) && \
	if [ -z "$$reproduce_tar" ]; then \
		echo "No .tar file found with prefix $(PROJECT_NAME)."; \
		exit 1; \
	else \
		echo "Loading Docker image from archive: $$reproduce_tar"; \
		$(DOCKER) load -i $$reproduce_tar >/dev/null && \
		loaded_image_id=$$(docker images -q | head -n 1); \
		if [ -z "$$loaded_image_id" ]; then \
			echo "Error: Failed to load image from $$reproduce_tar"; \
			exit 1; \
		else \
			echo "Tagging loaded image as $(IMAGE_NAME):latest"; \
			$(DOCKER) tag $$loaded_image_id $(IMAGE_NAME):latest; \
			$(DOCKER) rmi $$(docker images --format="{{.Repository}}:{{.Tag}}" | grep "$(PROJECT_NAME)-" | grep -v "$(IMAGE_NAME):latest") || true; \
			echo "Docker image loaded and tagged as $(IMAGE_NAME):latest"; \
		fi; \
	fi

.PHONY: jupyter
jupyter: on-docker ## Start Jupyter Notebook server inside Docker
	@jupyter lab --ip=0.0.0.0 --port=${JUPYTER_CONTAINER_PORT}

.PHONY: verify-cuda
verify-cuda: on-docker ## Verify CUDA installation
	@$(PYTHON) docker/verify_cuda.py

.PHONY: lint
lint: ## Run linter to check and fix code style issues
	@ruff check --fix

.PHONY: profile
profile: on-host ## Display Docker container profile
	@echo "CONTAINER_NAME: $(CONTAINER_NAME)"
	@echo "IMAGE_NAME: $(IMAGE_NAME)"
	@echo "JUPYTER_PORT: $$(docker port $(CONTAINER_NAME))"
	@echo "DATA_SOURCE: $(DATA_SOURCE)"

.PHONY: clean-docker
clean-docker: clean-container clean-image ## Remove Docker image and container
	
.PHONY: clean-container
clean-container: ## Force remove Docker container
	-$(DOCKER) rm -f $(CONTAINER_NAME)

.PHONY: clean-image
clean-image: ## Remove Docker image
	-$(DOCKER) image rm $(IMAGE_NAME)

.PHONY: destroy
destroy: on-host clean-docker ## DANGER! Completely remove project resources - YOU SHOULD KNOW WHAT WILL HAPPEN BEFORE RUN
	@read -p "Are you sure you want to completely remove $(PROJECT_NAME) directory and resources? (y/N): " confirm && \
	[ "$$confirm" = "y" ] && cd .. && rm -rf $(PROJECT_NAME) || echo "Aborted."
