# Cookiecutter-Docker-Research

Hey there! 👋 Welcome to my Cookiecutter-Docker-Research repo! If you've ever found yourself frustrated by trying to run deep learning projects on servers with messy, inconsistent environments, you're not alone.

Maybe you're still looking for an elegant remote development solution that works out-of-the-box, lets you connect and disconnect freely, and ensures no process is lost.

Or perhaps you want to package your entire project into a single file once it's done so you can save it, reproduce it anytime, or share it on GitHub without worrying about endless environmental issues.

Well, you've come to the right place! With Docker, PyTorch, and CUDA, you'll be up and running in under ten minutes.

Let's get started! 💪

## Features

- **Rapid Setup**: ⏰ Go from zero to hero in under ten minutes with easy, out-of-the-box configurations!
- **PyTorch Integration with CUDA Support**: 🚀 Harness the power of PyTorch and CUDA for cutting-edge deep learning applications, maximizing your GPU's potential with the [PyTorch NGC Container](https://catalog.ngc.nvidia.com/orgs/nvidia/containers/pytorch).
- **Non-root User Start-up**: 🦪 Automatically configure a standard user without the complexity of [Rootless mode](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html#rootless-mode), ensuring seamless access to files generated by the Docker container on the host.
- **Efficient Compression**: 🥪 Achieve fast, high compression ratios with [Zstandard](https://facebook.github.io/zstd/).
- **Easy Packaging and Reproduction**: 📦 Simplify packaging and ensure easy reproducibility of your environment and projects.
- **Optimized for Remote Development UX**: 🔦 Enhance your development experience in Visual Studio Code with the [Remote Development](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.vscode-remote-extensionpack) and [Docker](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-docker) extensions.

## Getting Started

### Prerequisites

- A currently supported Linux release (using outdated Linux releases is not recommended)
- [Docker Engine](https://docs.docker.com/engine/install/)
- [NVIDIA GPU Drivers](https://docs.nvidia.com/datacenter/tesla/tesla-installation-notes/index.html) (no need to install the NVIDIA CUDA Toolkit separately)
- [NVIDIA Container Toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html)
- [Cookiecutter](https://github.com/cookiecutter/cookiecutter)

### Quick Start 🌪️

Get your project set up with just five commands in ten minutes!

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
# Use this command anytime you lose connection
make attach-container

# Test your image and container, and verify the NVIDIA/CUDA environment
make verify-cuda

# Finished!
echo "Everything is done! Enjoy it!"
```

> **Troubleshooting**: Something went wrong? Want to remove everything? No problem!

```shell
# Remove all images and containers
make clean-docker

# Or just remove the container
make clean-container-force

# Be careful with the following command.
# It will remove the Docker image/container and also purge the project folder.
# Remove everything as if nothing happened
make destroying
```

> **Archiving**: Finished the whole project and want to archive it? Not trusting network storage? Want to keep everything local? Just one command!

> [!CAUTION]
> This feature is provided without any warranty for data security. It's recommended to follow proper backup protocols. Data backups should follow the [3-2-1 rule](https://en.wikipedia.org/wiki/Backup#:~\:text=The%203%2D2%2D1%20rule%20can%20aid%20in%20the%20backup%20process.%20It%20states%20that%20there%20should%20be%20at%20least%203%20copies%20of%20the%20data%2C%20stored%20on%202%20different%20types%20of%20storage%20media%2C%20and%20one%20copy%20should%20be%20kept%20offsite%2C%20in%20a%20remote%20location%20\(this%20can%20include%20cloud%20storage\).).

```shell
# The entire workdir and Docker environment will be packaged within a single file
make archive
```

The container will first be archived as `{project_name}-image-{date}.tar` in the `{project}` directory. Then, `{project_name}.tar.zst` and `{project_name}.tar.zst.sha256` files will be generated in the same directory.

> **Reproduction**: Want to relive your experience from years ago but can't remember what you did on that unremarkable afternoon?

```shell
# Verify the integrity of the archive file to ensure it hasn't been altered or corrupted via SHA256
sha256sum -c {project_name}.tar.zst.sha256

# Rebuild everything
make reproduce
```

Follow the instructions on the screen to enter the container:

```shell
Enter the container using the command:
docker exec -it {project_name}-container-20240520195529 /bin/bash
```

Just run the script in the folder. It's that simple!

## Known Issue

### Containers Losing Access to GPUs with Error: "Failed to initialize NVML: Unknown Error"

Here's a shell script consolidating solutions for the longstanding issue with Nvidia-container-toolkit, based on the following references:

- [https://github.com/NVIDIA/nvidia-container-toolkit/issues/48](https://github.com/NVIDIA/nvidia-container-toolkit/issues/48)
- [https://github.com/NVIDIA/nvidia-container-toolkit/issues/381#issuecomment-1976800649](https://github.com/NVIDIA/nvidia-container-toolkit/issues/381#issuecomment-1976800649)
- [https://github.com/NVIDIA/nvidia-docker/issues/1671#issuecomment-1740502744](https://github.com/NVIDIA/nvidia-docker/issues/1671#issuecomment-1740502744)
- [https://github.com/NVIDIA/nvidia-container-toolkit/issues/386#issuecomment-1970775940](https://github.com/NVIDIA/nvidia-container-toolkit/issues/386#issuecomment-1970775940)

```shell
# Update /etc/nvidia-container-runtime/config.toml to set no-cgroups to false
sudo sed -i 's/^no-cgroups = true/no-cgroups = false/' /etc/nvidia-container-runtime/config.toml && echo "Set no-cgroups to false in config.toml."

# Backup /etc/docker/daemon.json if it exists, then update with new configuration
[ -f /etc/docker/daemon.json ] && sudo cp /etc/docker/daemon.json /etc/docker/daemon.json.backup && echo "Backup created for daemon.json as daemon.json.backup."

# Add the necessary configuration to /etc/docker/daemon.json
sudo tee /etc/docker/daemon.json > /dev/null <<'EOF'
{
    "default-runtime": "nvidia",
    "runtimes": {
        "nvidia": {
            "args": [],
            "path": "nvidia-container-runtime"
        }
    },
    "exec-opts": ["native.cgroupdriver=cgroupfs"]
}
EOF

echo "Updated /etc/docker/daemon.json with a new configuration."
```

This script will apply the consolidated fixes by updating configurations for both Nvidia-container-runtime and Docker. Each step includes feedback messages for clarity.

## Contributions

Contributions are welcome! If you have improvements or bug fixes, please feel free to fork this repository and submit a pull request.

## Acknowledgements

Big shoutout to [Cookiecutter](https://github.com/audreyr/cookiecutter) and [cookiecutter-docker-science](https://docker-science.github.io/) for the major inspiration! Also, massive thanks to everyone contributing to the PyTorch community and the CUDA wizards at NVIDIA for the tech support.

Feel free to fork, star, and contribute! Happy coding! 🙌

