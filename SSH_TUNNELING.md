# One hop SSH tunnel

ssh -L 4444:192.168.1.13:22 seth@192.168.1.43 -N

-N -> Make tunnel only without executin any command.

# SSH Tunnel through multiple hops

- $ ssh -J user1@intermediate1,user2@intermediate2 user3@destination

# Using the ProxyCommand Option (More Flexible Approach)

- $ ssh -o ProxyCommand="ssh -W %h:%p user1@intermediate" user2@destination

# Use SSH tunneling to redirect web traffic

1. $ ssh -D 1080 -C user@ssh-server -N -q

-D 1080 tells SSH to create a SOCKS proxy on port 1080 on your local machine.
-C enables compression.
user@ssh-server is your username and the SSH server you're connecting to.

You can then configure your web browser to use this SOCKS proxy, directing all your browsing traffic through the SSH server.

or

2. $ ssh -J user@jump-host -D 1080 -C user@final-ssh-server

This command sets up a SOCKS proxy through a jump host. Your browsing traffic is encrypted and tunneled to the final-ssh-server, going through jump-host.

# Configuring Your Browser

- Firefox: Go to Preferences > General > Network Settings > Settings. Select “Manual proxy configuration”, enter “127.0.0.1” in the “SOCKS Host” field, and “1080” in the Port field. Choose SOCKS v5 and enable “Proxy DNS when using SOCKS v5”.

- Chrome/Chromium (and most other browsers): These don't have built-in SOCKS proxy support settings like Firefox. You generally need to start the browser with command-line arguments to use the proxy, or use an extension that enables proxy settings. For command-line use:

Windows: chrome.exe --proxy-server="socks5://127.0.0.1:1080"
Linux/macOS: google-chrome --proxy-server="socks5://127.0.0.1:1080"

# Port forwarding

## ssh -L (Local Port Forwarding)

This command forwards traffic from a local port on your machine to a remote machine via an SSH connection.

    ssh -L [local_port]:[remote_host]:[remote_port] [user@ssh_server]

Traffic sent to localhost:[local_port] on your machine is forwarded through the SSH tunnel to [remote_host]:[remote_port] on the remote side of the SSH connection.

The [remote_host] is resolved from the perspective of the SSH server.

    ssh -L 8080:example.com:80 user@ssh.server.com

This forwards traffic from localhost:8080 on your machine to example.com:80 via ssh.server.com.

You can now access example.com:80 by visiting http://localhost:8080 in your browser.

## ssh -R (Remote Port Forwarding)

Adjust /etc/ssh/sshd_config
SET:
GatewayPorts yes

This command forwards traffic from a remote port on the SSH server to a local machine via the SSH connection.

    ssh -R [remote_port]:[local_host]:[local_port] [user@ssh_server]

Traffic sent to localhost:[remote_port] on the SSH server is forwarded through the SSH tunnel to [local_host]:[local_port] on your local machine.

The [local_host] is resolved from the perspective of your local machine.

    ssh -R 9090:localhost:3000 user@ssh.server.com

This forwards traffic from localhost:9090 on the SSH server to localhost:3000 on your local machine.

Anyone with access to ssh.server.com can now access your local service by visiting http://localhost:9090 on the SSH server.

# IMPORTANT ----------------------

For port forwarding needs to enable options
in /etc/ssh/sshd_config:

For "ssh -R":
GatewayPorts yes

For both "ssh -R" and "ssh -L"
AllowTcpForwarding yes

## Tags:

-N: This tells SSH not to execute any commands
-f: To run the SSH process in the background
-C: Compress data
-q: Quite mode
-f: Run in background
