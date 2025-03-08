# Install docker on ubuntu

## Set password in "/etc/shadow"

General Rules for Salt in openssl passwd

The salt can be a random string (letters, numbers, symbols).
It is typically limited in length:

MD5 (-1 and -apr1): Up to 8 characters.

SHA-256 (-5) and SHA-512 (-6): Up to 16 characters.

If the salt contains special characters, enclose it in quotes ("" or '').
If you do not provide a salt, openssl will generate one automatically.

Generate salt:

    openssl rand -hex 8

Generate custom hash from password:

    openssl passws -5 --salt <HEX_SALT> <PASSWORD>

## Uninstall old versions

Before you can install Docker Engine, you need to uninstall any conflicting packages.

Your Linux distribution may provide unofficial Docker packages, which may conflict with the official packages provided by Docker. You must uninstall these packages before you install the official version of Docker Engine.

The unofficial packages to uninstall are:

docker.io
docker-compose
docker-compose-v2
docker-doc
podman-docker
Moreover, Docker Engine depends on containerd and runc. Docker Engine bundles these dependencies as one bundle: containerd.io. If you have installed the containerd or runc previously, uninstall them to avoid conflicts with the versions bundled with Docker Engine.

## Run the following command to uninstall all conflicting packages:

```bash
    for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove $pkg; done
```

apt-get might report that you have none of these packages installed.

Images, containers, volumes, and networks stored in /var/lib/docker/
aren't automatically removed when you uninstall Docker.
If you want to start with a clean installation, and prefer to
clean up any existing data, read the uninstall Docker Engine section.

## Installation methods

You can install Docker Engine in different ways, depending on your needs:

Docker Engine comes bundled with Docker Desktop for Linux.
This is the easiest and quickest way to get started.

Set up and install Docker Engine from Docker's apt repository.

Install it manually and manage upgrades manually.

Use a convenience script. Only recommended for testing and development environments.

## Install using the apt repository

Before you install Docker Engine for the first time on a new host machine,
you need to set up the Docker apt repository.
Afterward, you can install and update Docker from the repository.

Set up Docker's apt repository.

```bash
# Add Docker's official GPG key:

sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:

echo \
 "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
 $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
 sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
```

## Install the Docker packages.

## To install the latest version, run:

```bash
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

## Verify that the installation is successful by running the hello-world image:

```bash
sudo docker run hello-world
```

This command downloads a test image and runs it in a container.
When the container runs, it prints a confirmation
message and exits.

You have now successfully installed and started Docker Engine.

Tip

Receiving errors when trying to run without root?

The docker user group exists but contains no users,
which is why you’re required to use sudo to run Docker commands.
Continue to Linux postinstall to allow non-privileged users to run
Docker commands and for other optional configuration steps.

# Linux post-installation steps for Docker Engine

These optional post-installation procedures
describe how to configure your Linux host
machine to work better with Docker.

## Manage Docker as a non-root user

The Docker daemon binds to a Unix socket, not a TCP port.
By default it's the root user that owns the Unix socket,
and other users can only access it using sudo. The Docker
daemon always runs as the root user.

If you don't want to preface the docker command with sudo,
create a Unix group called docker and add users to it.
When the Docker daemon starts, it creates a Unix socket accessible
by members of the docker group. On some Linux distributions,
the system automatically creates this group when installing
Docker Engine using a package manager. In that case, there is no
need for you to manually create the group.

## Warning

The docker group grants root-level privileges to the user.
For details on how this impacts security in your system,
see Docker Daemon Attack Surface.

## Check existing groups:

    sudo cat /etc/group

    or Use the getent command

    getent group

1. Create the docker group.

   sudo groupadd docker

2. Add your user to the docker group.

   sudo usermod -aG docker $USER

3. Log out and log back in so that your group membership is re-evaluated.

You can also run the following command to activate the changes to groups:

    newgrp docker

## Verify that you can run docker commands without sudo.

    docker run hello-world

## ERRORS

If you initially ran Docker CLI commands using sudo
before adding your user to the docker group, you may see the following error:

WARNING: Error loading config file: /home/user/.docker/config.json -
stat /home/user/.docker/config.json: permission denied
This error indicates that the permission settings
for the ~/.docker/ directory are incorrect,
due to having used the sudo command earlier.

To fix this problem, either remove the ~/.docker/
directory (it's recreated automatically, but any custom settings are lost),
or change its ownership and permissions using the following commands:

    sudo chown "$USER":"$USER" /home/"$USER"/.docker -R
    sudo chmod g+rwx "$HOME/.docker" -R

# Configure Docker to start on boot with systemd

Many modern Linux distributions use systemd to manage which services
start when the system boots. On Debian and Ubuntu, the
Docker service starts on boot by default. To automatically start Docker
and containerd on boot for other Linux distributions using systemd,
run the following commands:

    sudo systemctl enable docker.service
    sudo systemctl enable containerd.service

To stop this behavior, use disable instead.

    sudo systemctl disable docker.service
    sudo systemctl disable containerd.service

You can use systemd unit files to configure the Docker service on startup,
for example to add an HTTP proxy, set a different directory or partition for
the Docker runtime files, or other customizations. For an example,
see Configure the daemon to use a proxy.

# Configure default logging driver

Docker provides logging drivers for collecting and viewing
log data from all containers running on a host. The default logging driver,
json-file, writes log data to JSON-formatted files on the host filesystem.
Over time, these log files expand in size, leading to potential exhaustion
of disk resources.

To avoid issues with overusing disk for log data,
consider one of the following options:

Configure the json-file logging driver to turn on log rotation.
Use an alternative logging driver such as the "local"
logging driver that performs log rotation by default.
Use a logging driver that sends logs to a remote logging aggregator.
