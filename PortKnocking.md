
### Port Knocking server protection

Protect server SSH connection

1. Change default SSH port 

2. Conect to SSH usinf connection keys and forbid password connection

3. Use Passphrase to encode the private key 

4. SSH with non root user only 

5. Use Port Knocking 


Create SSH keys:

$ ssh-keygen -t ed25519 -> Newer and more rliable than RSA 


Create user 

- $ adduser <username>


Add user to sudo group

- $ sudo adduser www sudo 


SSH Settings

- $ vim /etc/ssh/sshd_config

Set:

PermitRootLogin no 
PasswordAthentication no
AllowUsers <username> <...> <...>  

Change port
Port 45916 -> Example


Copy ssh key to the server

- $ ssh-copy-id <host@port>


Restart SSH service

- $ sudo service sshd restart 

- $ sudo systemctl restart sshd


Check if port is in use

- $ sudo ss -tuln | grep 45916


## Port Knocking 

# Setup using IP tables 

- $ sudo apy install -y knockd

# Edit knockd config 

- $ sudo vim /etc/knockd.conf

[options]
        UseSyslog
        Interface = <available interface> [$ ip a]

[SSH]
        sequence    = 7000,8000,9000
        seq_timeout = 5
        tcpflags    = syn
        command = /sbin/iptables -I INPUT -s %IP% -p tcp --dport 22 -j ACCEPT
        cmd_timeout = 60 



# Set autolaunch 

- $ sudo vim /etc/default/knockd

START_KNOCKD=1
KNOCKD_OPTS="-i eth0"


# Start knockd deamon 

- $ sudo systemctl start knockd


# Add knockd to autoload 

- $ sudo systemctl enable knockd 


# Set up iptables 

...



