## Server Ubuntu SetUp

    1. Make auto-updates
    	% sudo apt update && sudo apt upgrade

    	Make it automated:
    	% sudo apt install unattended-upgrades

    	Config file:
    	% nano /etc/apt/apt.conf.d/50unattended-upgrades

    	Enable autoupdates:
    	% dpkg-reconfigure --priority=low unattended-upgrades

    	Verify:
    	% sudo systemctl status unattended-upgrades

    	Disable:
    	stop -	% sudo systemctl stop unattended-upgrades
    	disable  - % sudo systemctl disable unattended-upgrades

    2. Create admin user:
    	% useradd -m -s /bin/bash admin && passwd admin
    		-m -> created home dir for used -> /home
    		-s  -> specifies user login shell -> /bin/bash

    3. Assign new user to a group
    	Check user group
    	% groups [user name]
    	or
    	% id [user name]

    	Check available groups in file /etc/sudoers.d
    	% visudo
    	Groups start with '%' are available

    	Assign group
    	% usermog -aG [group name] [user name] (sudo or admin or both)
    4. Change user
    	% su - [user name]

    5. Disable permission for root login
    	In file
    	% sudo vim /etc/ssh/sshd_config
    	set -> PermitRootLogin no
    	add -> AllowUsers [user name]

    6. Limit ssh connetion to avoid brute-force attack
    	% sudo ufw limit 22/tcp

    7. Restart ssh
    	% sudo systemctl restart ssh

    8. Info about open port
    	% sudo ss -atpu

## OpenVPN connection

# 1 Install openvpn and easy-rsa

    % apt install openvpn easy-rsa

# 2 Copy default easy-rsa dir to the /home dir

    % make-cadir ~/openvpn-ca
    change dir to the created one

# 3 Edit 'vars' file using nano to:

set_var EASYRSA_REQ_COUNTRY "US"
set_var EASYRSA_REQ_PROVINCE "NY"
set_var EASYRSA_REQ_CITY "New York"
set_var EASYRSA_REQ_ORG "DigitalOcean"
set_var EASYRSA_REQ_EMAIL "admin@admin.net"
set_var EASYRSA_REQ_OU "Community"

    NOT NESSESARY TO CHANGE ANY DATA

Or somethig similar, the key point is to change the vars.

# 4 Create Certification center, PKI stands for Public Key Infrastructure

    1. Initialize the PKI:
    	% ./easyrsa init-pki
    2. Build the Certificate Authority (CA):
    	% ./easyrsa build-ca

# 5 Generate Certificate, Keys and encryption files for the server

    1. Generate a Certificate Request:
    	% ./easyrsa gen-req server nopass
    2. Sign the Certificate Request:
    	% ./easyrsa sign-req server server
    3. Generate a new Diffie-Hellman Parameters (NOT required):
    	% ./easyrsa gen-dh
    	takes several minutes
    4. Generate a new TLS-Auth Key (optional but recommended for added security):
    	% openvpn --genkey secret pki/ta.key

# 6 Create sertificate and key pair for the client

    1. Generate a Certificate Request for the Client
    	% ./easyrsa gen-req [client name] nopass
    2. Sign the Certificate Request:
    	% ./easyrsa sign-req client [client name]
    3. Connect client MAC OS
    	% sudo openvpn --config [file.conf]

# 7 OpenVPN Service configuration

    1. Copy files to /etc/openvpn (default location)
    	%  sudo cp ca.crt private/ca.key issued/server.crt private/server.key ta.key dh.pem /etc/openvpn
    2. Copy server.conf from examples to working dir (/etc/openvpn)
    	% sudo cp /usr/share/doc/openvpn/examples/sample-config-files/server.conf /etc/openvpn/server.conf

    	Edit server config:

    	tls-auth ta.key 0 # Exists
    	key-direction 0 # Add this

    	cipher AES-256-CBC # Exists
    	auth SHA256 # Add this

    	Set:
    	proto udp or udp4 for IPv4

    	Uncomment:

    	user nobody
    	group nogroup

    	push "redirect-gateway def1 bypass-dhcp"

    	push "dhcp-option DNS 208.67.222.222"
    	push "dhcp-option DNS 208.67.220.220"

    	to the server.conf

# 8 Set server network configuration (Firewall)

    1. Edit /etc/sysctl.conf
    	% sudo vim /etc/sysctl.conf

    	Uncomment:
    	net.ipv4.ip_forward=1

    	Apply changes:
    	sudo sysctl -p

    2. UFW (Uncomplicated Firewall) settings to hide client connection
    	% ip route | grep default
    		via 172.104.148.1 dev eth0 proto static

    	% sudo vim /etc/ufw/before.rules

    		Add this to the begining of the file:

    		[change web interface to the result from previous command. in this case  - eth0]

# START OPENVPN RULES

# NAT table rules

\*nat
:POSTROUTING ACCEPT [0:0]

# Allow traffic from OpenVPN client to eth0

-A POSTROUTING -s 10.8.0.0/8 -o eth0 -j MASQUERADE
COMMIT

# END OPENVPN RULEs

    3. Set for UFW DEFAULT_FORWARD_POLICY="ACCEPT"
    VERY IMPORTANT !!! No Forward No Internet
    	% sudo vim /etc/ufw/ufw.conf

    	Add line:
    	DEFAULT_FORWARD_POLICY="ACCEPT"

    4. Protect ssh from brutforce attack
    	% sudo ufw limit ssh/tcp

    4. Open VPN port and Apply changes

    	% sudo ufw allow 1194/udp
    	% sudo ufw allow OpenSSH
    	% sudo ufw default allow outgoing


    	% sudo ufw disable
    	% sudo ufw enable

# 9 Run server

    1. Run server
    	%  sudo systemctl start/stop/status openvpn@server
    	or
    	% sudo openvpn --config /etc/openvpn/server.conf

    2. Check the server is running
    	% sudo systemctl status openvpn@server

    3. Check logs in case it fails
    	% journalctl -xe | grep openvpn

    4. Check availability of OpenVPN interface
    	% ip addr show tun0

    5. Config service to automatically enabled once the server is up
    	% sudo systemctl enable openvpn@server


    6. View system logs in case of failure
    	% sudo tail -n 50 /var/log/syslog

    7. Test server.conf file
    	% sudo openvpn --config /etc/openvpn/server.conf --check

# 10 Client settings (On client machine)

    1. Modify client.conf file

    	tls-auth ta.key 1
    	key-direction 1

    	cipher AES-256-CBC
    	auth SHA256

    	Edit 'remote' option:
    	remote [server ip] 1194

    	START VPN:
    	$ sudo openvpn --config [file.conf]

# 11 Revoke certificate

    0. Check if you can read the certificate
    	% openssl rsa -in /home/admin/openvpn-ca/pki/private/ca.key -check

    1. In the ~/openvpn-ca  dir:
    	% ./easyrsa revoke new_client_name
    	% ./easyrsa gen-crl

    	will create file: crl.pem

    2. Move the file to the /etc/openvpn

    3. Add to the server.conf
    	crl-verify crl.pem

    4. Restart server
    	% sudo systemctl restart openvpn@server

# OTHER

    1. Check the file with File Descriptors (fd=7)
       related to the process 1312

    	% lsof -p 1312 | grep 7

    2. Get logs in real time

    	% sudo journalctl -fu openvpn

    3. Allow outgoing traffic SOLVES: "write UDPv4 Operation not permitted (fd=7,code=1)"

    	% sudo ufw default allow outgoing

    	sudo iptables -P INPUT ACCEPT
    	sudo iptables -P OUTPUT ACCEPT
    	sudo iptables -P FORWARD ACCEPT
    	sudo iptables -F

    	FOR UFW
    	sudo ufw default allow incoming
    	sudo ufw default allow routed

    	Flush Rules:
    	sudo ufw --force reset

    4. Check iptables rules
    	% sudo iptables -L
    5. Check CPUs
    	% lscpu
    6. Check RAM
    	% free -h
    7. Check disk
    	% du -h
    8. Check GPU
    	% lspci | grep -i vga
    9. Check network
    	% ifconfig
    	% ip addr
    10. Check USB devices
    	% lsusb
    11. Full info about hardware
    	% lshw
    		In some cases needs to be installed.
    		% sudp apt install lshw
    12. Speedtes
    	% sudo apt install speedtest-cli
    	% speedtest
    	% speedtest --simple

    	List of available srvers
    	% speedtest --list
    	% speedtest --server <server_id>
    13. Check ununtu verions
    	% lsb_release -a

    14. Check IP and country

    	#!/bin/bash

    	# Get the server's public IP address
    	IP=$(curl -s http://ipinfo.io/ip)

    	# Get the country information using the IP address
    	COUNTRY=$(curl -s http://ipinfo.io/${IP}/country)

    	echo "Server Country: $COUNTRY"



# Generate and setup ssh connection:

    1. Create ~/.ssh/config file

    	""""""

    	# Default key for all connections
    	Host *
    	  IdentityFile ~/.ssh/id_rsa

    	# Specific key for the root user on Remote Server 1
    	Host remote_server1
    	  HostName 203.0.113.1
    	  User root
    	  IdentityFile ~/.ssh/id_rsa_root

    	# Specific key for the admin user on Remote Server 2
    	Host remote_server2
    	  HostName 203.0.113.2
    	  User admin
    	  IdentityFile ~/.ssh/id_rsa_admin

    	""""""

    2. Create key:
    	% ssh-keygen -t rsa -b 2048 -f ~/.ssh/[file-name]
    	-C "[user@host]"


    - Copy the public key to the server

    3. Automated copy:
    	% ssh-copy-id -i ~/.ssh/id_rsa_admin.pub admin@remote_server_ip

    4. Manual copy:
    	% cat ~/.ssh/id_rsa_admin.pub | ssh admin@remote_server_ip
    	"mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys"


    5. Adjust permissions on the server:
    	% ssh admin@remote_server_ip "chmod 700 ~/.ssh && chmod 600
    	~/.ssh/authorized_keys"

    6. Test new key:
    	% ssh -i ~/.ssh/[key-name] admin@remote_server_ip

    7. Add new key to the config file and test
    	% ssh [new-record-name]

    8. Remove passphrase from the private key
    	% ssh-keygen -p -f ~/.ssh/id_rsa

    9. Store passphrase in ssh-agent
    A more secure option is to use an SSH agent. The SSH agent can
    store your decrypted private key in memory,
    eliminating the need to enter the passphrase
    every time you connect.

    Start the SSH agent:
    % eval "$(ssh-agent -s)"

    Add your private key to the SSH agent:
    % ssh-add ~/.ssh/id_rsa

    Automate the process:
    Add to ~/.zshrc

    if [ -z "$SSH_AUTH_SOCK" ] ; then
    	eval "$(ssh-agent -s)"
    	ssh-add
    fi

    10. Connect using password

    	% ssh -o PasswordAuthentication=yes -o PreferredAuthentications=password root@172.105.91.53

    	or add next lien to "config" file

    	...

    	User [your_username]
    	PasswordAuthentication yes

    	...




### Let's Encrypt - service that provides free Certificates.

# NGINX

    0. Globak config
    	/etc/nginx/nginx.conf

    1. Install
    	% sudo apt install nginx
    2. Create config file in
    	% cd /etc/nginx/sites-available
    3. Create symbolic linkto 'sites-enabled'
    	% sudo ln -s /etc/nginx/sites-available/proxy.conf /etc/nginx/sites-enabled/
    4. Test NGINX configuration
    	% sudo nginx -t
    5. Reload the NGINX
    	% sudo service nginx reload
    6. Start server
    	% sudo service nginx start/stop/status
    7. View logs
    	% sudo tail -f /var/log/nginx/error.log

# Issue HTTPS Certificates using Certbot

    1. Remove certbot-auto and any Certbot OS packages
    	% sudo apt remove certbot
    2. Install 'snap'
    	% sudo apt install snapd
    	Test:
    	% sudo snap install hello-world
    	% hello-world
    3. Install 'certbot'
    	% sudo snap install --classic certbot
    4. Ensure that 'certbot' command can be run
    	% sudo ln -s /snap/bin/certbot /usr/bin/certbot
    5. Issue certificates with automated setup
    	% sudo certbot --nginx
    6. Just issue certificates
    	% sudo certbot certonly --nginx
    7. Test automatic renewal
    	% sudo certbot renew --dry-run

    	The command to renew certbot is installed in one of the
    	following locations:

    	/etc/crontab/
    	/etc/cron.*/*
    	systemctl list-timers

# Install Docker

    1. Run the following command to uninstall all conflicting packages:
    	% for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt remove $pkg; done
    2. Setup Docker repository:

    	# Add Docker's official GPG key:

    	sudo apt-get update
    	sudo apt-get install ca-certificates curl gnupg
    	sudo install -m 0755 -d /etc/apt/keyrings
    	curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    	sudo chmod a+r /etc/apt/keyrings/docker.gpg


    	# Add the repository to Apt sources:

    	echo \

"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
 $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
 sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

    3. To install the latest version, run:

    	% sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    4. Verify that the Docker Engine installation is successful by running the hello-world image.

    	% sudo docker run hello-world

### AdGuard

    1. Install Docker

    2. Download and run:
    	# Download install file
    	% curl -o install.sh -L https://github.com/AdguardTeam/AdGuardHome/raw/master/scripts/install.sh

    	# Install and run
    	% sudo sh install.sh

    3. Control:
    	AdGuard Home is now installed and running
    	you can control the service status with the
    	following commands:

    	sudo /opt/AdGuardHome/AdGuardHome -s
    	start|stop|restart|status|install|uninstall

    4. Check on what port and PID the AdGuard is running:
    	% sudo ss -tulpn | grep AdGuardHome

    5. Check local machine network info
    	% ip a

    6. Server works on port :3000.
    	Open allow this port in UFW

    7. Check Running Processes
    	% sudo ss -tulpn | grep AdGuardHome

    8. Check DNS Requests
    	% dig @[ip] domain.domain

    9. Network Troubleshooting
    	% traceroute www.google.com

    10. Stop systemd-resolved
    	% sudo systemctl stop systemd-resolved
    	% sudo systemctl disable systemd-resolved

    11. Verify Configuration
    	% scutil --dns

    12. To check if your DNS server at IP address 172.232.60.75 is reachable
    	% nc -zv 172.232.60.75 53

    	-z: Specifies that nc should not send any data.
    	-v: Enables verbose mode, providing more
    	detailed output.

    13. Check what works on port 53
    	% sudo lsof -i :53

    14.

### Setup iRedMail

    1. Update Linux

    2. Install iRedMail from thir site using 'wget'
    	Download from thir website:
    	https://www.iredmail.org/download.html

    3. Unpack
    	% tar -xzvf [file-name]
    	% cd iRedMail-[version]

    4. Determaine FQDN
    	% sudo nano /etc/hosts
    	add this line:
    	127.0.1.1 mail.sethlab.net mail
    	127.0.0.1 mail.sethlab.net mail localhost localhost.localdomain
    	139.162.246.251 mail.sethlab.net mail

    5. Set the Hostname to match SQDN
    	% sudo hostnamectl set-hostname mail.sethlab.net

    	# resolve no condidate issue for 'netcat'
    	change netcat to netcat-openbsd in
    	./iRedMail/functions/packages.sh

    	% sudo chmod +x iRedMail.sh
    6. Run
    	% sudo ./iRedMail.sh

    	# INFO file
    	/root/iRedMail-1.6.8/iRedMail.tips

    7. Access via browser

    	username: postmaster@sethlab.net
    	password: admin613
    	dbpassword: mariadb

    	SSL cert keys (size: 4096):
    	- /etc/ssl/certs/iRedMail.crt
    	- /etc/ssl/private/iRedMail.key

    	Mail Storage:
    	- Mailboxes: /var/vmail/vmail1
    	- Mailbox indexes:
    	- Global sieve filters: /var/vmail/sieve
    	- Backup scripts and backup copies: /var/vmail/backup

    	Admin:
    	https://[host]/iredadmin


    	Client:
    	https://[host]/mail

