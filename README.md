# cookiecutter-docker-research

👋 Welcome to the QuickStart Deep Learning project! This repository is your one-stop-shop, equipped with a Docker setup that lets you kick off a PyTorch with CUDA deep learning project in under ten minutes. Let's dive in!

## Features

- **Rapid Setup**: ⏰ Go from zero to hero in under ten minutes with comfortable out-of-the-box configurations!
- **PyTorch Integration with CUDA Support**: 🚀 Harness the power of PyTorch and CUDA for cutting-edge deep learning applications, maximizing your GPU's potential based on the [PyTorch NGC Container](https://catalog.ngc.nvidia.com/orgs/nvidia/containers/pytorch).
- **Non-root user start-up:** 🪪 Avoid permission issues when accessing files generated by the Docker container on the host.
- **Efficient Compression**: 🥪 Achieve fast and high compression ratios with [Zstandard](https://facebook.github.io/zstd/).
- **Easy Packaging and Reproduction**: 📦 Simplify packaging and ensure easy reproducibility of your environment and projects.
- **Optimized for Remote Development UX**: 🛠 Tailored to enhance your development experience in Visual Studio Code with the [Remote development](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.vscode-remote-extensionpack) and [Docker](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-docker) extensions.

## Getting Started

### Prerequisites

- Currently supported Linux releases (using staled Linux is not a wise choice)
- [NVIDIA GPU Drivers](https://docs.nvidia.com/datacenter/tesla/tesla-installation-notes/index.html) (not necessary to install the NVIDIA CUDA Toolkit)
- [Cookiecutter](https://github.com/cookiecutter/cookiecutter)
- [Docker Engine](https://docs.docker.com/engine/install/)

### Quick Start 🌪️

How can you build a clear project with just 5 commands in 10 minutes? Just watch!

```shell
# Download and initialize the cookiecutter template in interactive mode
cookiecutter gh:venturi123/cookiecutter-docker-research

# Change the working directory to the project folder
cd {path/to/your/project}

# Build the Nvidia PyTorch Docker image
make init

# Start a Docker container instance
make create-container

# Attach to the container
# You can safely use this command every time you lose connection
make attach-container

# Test your image and container, also the NVIDIA/CUDA environment
make verify-cuda

# Finished!
echo "Everything is done! Enjoy it!"
```

> Something went wrong? Want to remove everything? No problem!

```shell
# Remove all images and containers
make clean-docker

# Or just remove the container
make clean-container-force

# Attention: You should be very careful using the following command.
# Not only will the Docker image/container be removed, but the project folder will also be purged.
# Remove everything as if nothing happened
make destroying
```

> Finished the whole project and want to archive it? Don't trust network storage? Want to keep everything local? Just one command!

```shell
# The entire workdir and Docker environment will be packaged within one single file
make archive
```

The container will first be archived as `{project_name}-image-{date}.tar` and placed in the `{project}` directory. Then, the `{project_name}.tar.zst` and `{project_name}.tar.zst.sha256` files will be generated in the same directory as the project directory.

> Want to relive your experience from many years ago but can't remember what you did on that unremarkable afternoon? 

```shell
# Verify the integrity of the archive file, ensuring that it has not been altered or corrupted via SHA256
sha256sum -c {project_name}.tar.zst.sha256

# Rebuild everything
make reproduce
```

Follow the tips on the screen to enter the container:

```shell
Enter the container using the command:
docker exec -it {project_name}-container-20240520195529 /bin/bash
```

Just run the script in the folder. It's that simple!

## Contributions

Contributions are welcome! If you have improvements or bug fixes, please feel free to fork this repository and submit a pull request.

## Acknowledgements

Big shoutout to [Cookiecutter](https://github.com/audreyr/cookiecutter) and [cookiecutter-docker-science](https://docker-science.github.io/) for the major inspo! Also, massive thanks to everyone contributing to the PyTorch community and the CUDA wizards at NVIDIA for the tech support.

Feel free to fork, star, and contribute! Happy coding! 🙌
