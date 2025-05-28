.DEFAULT_GOAL := help

###########################################################################################################
## VARIABLES
###########################################################################################################

export DOCKER=docker
export PWD=$(shell pwd)
export HOST_UID=$(shell id -u)
export HOST_GID=$(shell id -g)
export PROJECT_NAME={{ cookiecutter.project_slug }}
export IMAGE_NAME=$(PROJECT_NAME)-image
export CONTAINER_NAME=$(PROJECT_NAME)-container
export DATE=$(shell date +%Y%m%d%H%M%S)

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
init: on-host check-docker-installed ## Build the Docker image for the project
	@$(DOCKER) build -t $(IMAGE_NAME) -f docker/Dockerfile \
		--build-arg USER_UID=$(HOST_UID) \
		--build-arg USER_GID=$(HOST_GID) .

.PHONY: init-no-cache
init-no-cache: on-host check-docker-installed ## Build the Docker image without cache
	@$(DOCKER) build --no-cache -t $(IMAGE_NAME) -f docker/Dockerfile \
		--build-arg USER_UID=$(HOST_UID) \
		--build-arg USER_GID=$(HOST_GID) .

.PHONY: create-container
create-container: on-host check-docker-installed ## Create and start a detached Docker container
	@$(DOCKER) run -d --gpus all --ipc=host --pid=host --network host --runtime=nvidia \
		-v "${PWD}:/home/docker/${PROJECT_NAME}" \
		-v "${HOME}/.ssh:/home/docker/.ssh" \
		-v "${HOME}/.gitconfig:/home/docker/.gitconfig" \
		--name $(CONTAINER_NAME) \
		$(IMAGE_NAME) tail -f /dev/null

.PHONY: attach-container
attach-container: on-host ## Attach to a running Docker container
	@$(DOCKER) start $(CONTAINER_NAME) || true
	@$(DOCKER) exec -it $(CONTAINER_NAME) /bin/bash

.PHONY: backup
backup: ## fast backup
	@bash docker/backup.sh "$(shell echo $(filter-out $@,$(MAKECMDGOALS)) | sed 's/^/ /' | sed 's/ $$//')"
%:
	@:

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
	@cd .. && tar -czf $(PROJECT_NAME).tar.gz $(PROJECT_NAME) && sha256sum $(PROJECT_NAME).tar.gz > $(PROJECT_NAME).tar.gz.sha256
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
			$(DOCKER) rmi $$(docker images --format={% raw %}"{{.Repository}}:{{.Tag}}"{% endraw %} | grep "$(PROJECT_NAME)-" | grep -v "$(IMAGE_NAME):latest") || true; \
			echo "Docker image loaded and tagged as $(IMAGE_NAME):latest"; \
		fi; \
	fi

.PHONY: verify-cuda
verify-cuda: on-docker ## Verify CUDA installation
	@python docker/verify_cuda.py

.PHONY: install-latex-full
install-latex-full: on-docker ## Install LaTeX (scheme-full, 7+GB)
	@bash docker/install_latex.sh
	@echo "source ~/.bashrc to finish the installation"

.PHONY: install-latex-small
install-latex-small: on-docker ## Install LaTeX (scheme-small, enable Matplotlib latex backend)
	@bash docker/install_latex_small.sh
	@echo "source ~/.bashrc to finish the installation"
	
.PHONY: lint
lint: ## Run linter to check and fix code style issues
	@ruff check --fix

.PHONY: profile
profile: on-host ## Display Docker container profile
	@echo "CONTAINER_NAME: "
	@echo $(CONTAINER_NAME)
	@echo
	@echo "IMAGE_NAME: "
	@echo $(IMAGE_NAME)
	@echo
	@echo "IP_ADDRESS: "
	@echo $$(docker inspect -f '{% raw %}{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}{% endraw %}' $(CONTAINER_NAME))
	@echo
	@echo "Ports: "
	@docker inspect -f '{% raw %}{{range $$containerPort, $$bindings := .HostConfig.PortBindings}}{{range $$bindings}}{{println .HostPort "->" $$containerPort}}{{end}}{{end}}{% endraw %}' $(CONTAINER_NAME) | sed 's/^/  /'
	@echo
	@echo "Mounts: "
	@docker inspect -f '{% raw %}{{range .Mounts}}{{println .Source "->" .Destination}}{{end}}{% endraw %}' $(CONTAINER_NAME) | sed 's/^/  /'
	@echo
	@echo "Environment variables: "
	@docker inspect -f '{% raw %}{{range .Config.Env}}{{println .}}{{end}}{% endraw %}' $(CONTAINER_NAME) | sed 's/^/  /'
	@echo

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
