# Initial setup

## 1. Connect to server via ssh and perform updates:

    sudo apt update && sudo apt upgrade -y

## 2. Install nessesary dependencies:

    Default dependencies

    sudo apt install -y tmux htop git curl wget unzip zip gcc build-essential make less zsh

## 3. Create sudo user to connect to the server from this user instead of 'root':

    adduser www (user-name)

    or

    useradd -m -s /bin/bash <username>
    -m => Create home directory for user
    -s => Specify user shell

    passwd <username> => set password

    (sudo useradd -e 2024-12-31 username => set exparation date for the user)

    usermod -aG sudo <username>

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

## User Setup

### 1. Set password expiration to 90 days:

    sudo chage -M 90 www

### 2. Set warning before expiration to 14 days:

    sudo chage -W 14 www

### 3. Disable account 30 days after password expiration:

    sudo chage -I 30 www

### 4. View current settings:

    sudo chage -l www

# Create key and copy it to the remote server:

    ssh-keygen -t rsa -b 2048

    ssh-copy-id -i /path/to/key [user-name]@[ip]

# Create "~/.ssh/conf" file to connect automatically:

```conf

# Default key for all connections
Host *
  IdentityFile ~/.ssh/id_rsa

# Specific key for the root user on Remote Server 1
Host de
  HostName 172.104.156.127
  User root
  IdentityFile ~/.ssh/id_rsa

#Specific key for the admin user on Remote Server 2
Host dewww
	HostName 172.104.156.127
	User www
	IdentityFile ~/.ssh/id_rsa

Host i5
	HostName 192.168.1.11
	User seth
	IdentityFile ~/.ssh/id_rsa

# Host gb
# 	HostName 139.162.246.251
# 	User root
# 	Port 45916
# 	IdentityFile ~/.ssh/id_rsa
#
```

## Forbid connection from root user:

## Make changes to /etc/ssh/sshd_config. Add:

    AllowUsers [user-name]
    PermitRootLogin no
    PasswordAuthentication no
    PubkeyAuthentication yes

# Open SOCKS5 socket

ssh -D [local_port] -q -C -N user@remote_host

example:
ssh -D 1080 -q -C -N user@192.168.1.1

-D [local_port]: Specifies the local port for the SOCKS proxy.

-q: Enables quiet mode, suppressing warnings and diagnostic messages.

-C: Enables compression for the data being sent through the tunnel.

-N: Tells SSH not to execute any commands on the remote server, useful for just forwarding ports.

-f: Execute in background
