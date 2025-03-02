


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
