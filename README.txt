 
# Initial setup 

1. Connect to server via ssh and perform updates:
	
	sudo apt update && sudo apt upgrade -y 

2. Install nessesary dependencies:
	Default dependencies 

	sudo apt install -y tmux htop git curl wget unzip zip gcc build-essential make less zsh

3. Create sudo user to connect to the server from this user instead of 'root':

	adduser www (user-name)

	or

	useradd -m -s /bin/bash <username>
	-m => Create home directory for user 
	-s => Specify user shell

	passwd <username> => set password

	(sudo useradd -e 2024-12-31 username => set exparation date for the user)

	usermod -aG sudo <username>

Create key and copy it to the remote server:

	ssh-keygen -t rsa -b 2048 

	ssh-copy-id -i /path/to/key [user-name]@[ip]

Forbid connection from root user:

Make changes to /etc/ssh/sshd_config 

Add 
	AllowUsers [user-name]
	PermitRootLogin no 
	PasswordAuthentication no
	PubkeyAuthentication yes


Open SOCKS5 socket

ssh -D [local_port] -q -C -N user@remote_host

example: 
ssh -D 1080 -q -C -N user@192.168.1.1

-D [local_port]: Specifies the local port for the SOCKS proxy.

-q: Enables quiet mode, suppressing warnings and diagnostic messages.

-C: Enables compression for the data being sent through the tunnel.

-N: Tells SSH not to execute any commands on the remote server, useful for just forwarding ports.

-f: Execute in background
	
