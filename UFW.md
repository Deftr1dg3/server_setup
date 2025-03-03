# Below is a comprehensive guide to using ufw

# (Uncomplicated Firewall) on Ubuntu. This guide covers:

## 1. Installing and enabling ufw.

Basic ufw usage (default policies, listing, enabling/disabling).
Opening and closing specific ports to outside traffic.
Working with Docker and ufw, including how to allow container traffic while still protecting your host.

### Introduction to ufw

ufw (Uncomplicated Firewall) is a user-friendly
wrapper around the more complex iptables.
It simplifies most common firewall needs:

Allowing or denying inbound connections (by service or port).
Setting default policies.
Logging firewall activity. 2. Installing and Enabling ufw
Install ufw

On Ubuntu (if ufw is not already installed):

    sudo apt update
    sudo apt install ufw

Check ufw Status

    sudo ufw status verbose

If it is not enabled, the status will show as inactive.

### Enable ufw

To enable ufw (start enforcing rules):

    sudo ufw enable

### Disable ufw

If for any reason you need to disable ufw:

    sudo ufw disable

## 2. Basic ufw Usage

Default Policies

It is good practice to set a default deny policy for
incoming traffic and a default allow policy for
outgoing traffic. These are often the recommended defaults:

    sudo ufw default deny incoming
    sudo ufw default allow outgoing

This ensures that any port you don’t
explicitly open is blocked from inbound connections,
while all outbound traffic is allowed.

## 3. Listing and Deleting Rules

List current ufw rules:

    sudo ufw status numbered

The numbered option shows an index beside each rule,
which makes deleting specific rules easier.

### Delete a rule:

List rules with

    sudo ufw status numbered

Identify the rule number (e.g. 3).
Delete with:

    sudo ufw delete <rule_number>

For example:

    sudo ufw delete 3

### Allow or Deny Specific Ports

Open a port (e.g. TCP port 22 for SSH):

    sudo ufw allow 22/tcp

Close (deny) a port (e.g. port 80):

    sudo ufw deny 80/tcp

### Allow a port for UDP:

    sudo ufw allow 123/udp

### Allow or Deny a range (e.g. 6000-6007 on TCP):

    sudo ufw allow 6000:6007/tcp

or

    sudo ufw deny 6000:6007/udp

## 4. Allow or deny acces based on source:

When you want to restrict access to a service or port based
on source IP or source network, you can use the
allow from ... to ... syntax in ufw.
The general pattern is:

    sudo ufw allow from <SOURCE> to <DESTINATION> port <PORT> proto <PROTOCOL>

### Allow a Specific IP Address

Example
Allow a single IP address 192.168.1.100 to access TCP port 22 (SSH) on your host:

sudo ufw allow from 192.168.1.100 to any port 22 proto tcp

- from 192.168.1.100: The source IP address.
- to any port 22: The destination is “any” IP on this machine
  (the firewall), specifically port 22.
- proto tcp: Restricts this rule to TCP (instead of UDP).

This rule means:

Only the host at 192.168.1.100 is allowed through ufw on port 22 (TCP).
Any other IP addresses are still subject to your default policy or
other rules for port 22.

### Allow a Specific Subnet

Example
Allow an entire subnet 192.168.1.0/24 to access TCP port 80 on your host:

    sudo ufw allow from 192.168.1.0/24 to any port 80 proto tcp

192.168.1.0/24 means all IPs in the 192.168.1.x range (255 possible hosts).
to any port 80 means they can access port 80 on the firewall’s network interfaces.

### Allow from Anywhere (but still specify destination)

You can also specify the destination IP if your system
has multiple network interfaces or multiple IP addresses.
For instance, if your server has an internal
interface with IP 10.0.0.5 and you only want to allow
traffic on that interface:

    sudo ufw allow from 192.168.1.100 to 10.0.0.5 port 8080 proto tcp

This way, traffic is only allowed to the
host’s IP 10.0.0.5 (on port 8080) from 192.168.1.100.
Other interfaces or IPs on the same machine wouldn’t match this rule.

### Deny from a Specific IP or Subnet

If instead of allowing, you want to deny:

    sudo ufw deny from 203.0.113.45 to any port 22 proto tcp

This prevents connections from 203.0.113.45 to port 22.

### Checking and Verifying the Rule

After you add a rule, run:

    sudo ufw status numbered

Look for the newly added rule. It should appear like:

    [ 1] Anywhere ALLOW IN 192.168.1.100 22/tcp

(or a similar format, depending on how ufw lists it).

### Deleting or Modifying the Rule

Delete by number (easiest way):

List all rules with numbers:

    sudo ufw status numbered

Find the rule number (e.g., 1).
Delete the rule:

    sudo ufw delete 1

Delete by specification (more prone to typos):

    sudo ufw delete allow from 192.168.1.100 to any port 22 proto tcp

Summary of allow from ... to ...
Single IP:

    sudo ufw allow from 1.2.3.4 to any port 80 proto tcp

Subnet:

    sudo ufw allow from 192.168.100.0/24 to any port 443 proto tcp

Specify Destination IP:

    sudo ufw allow from 10.0.0.0/24 to 10.0.0.5 port 3306 proto tcp

Deny Instead of Allow:

    sudo ufw deny from 8.8.8.8 to any port 22 proto tcp

List and Delete:

    sudo ufw status numbered
    sudo ufw delete <rule_number>

Use these patterns to fine-tune your firewall rules
for specific inbound traffic sources.

## 5. Check user rules:

### Check in user.rules file

    sudo cat /etc/ufw/user.rules
    sudo cat /etc/ufw/user6.rules

Look for the rule corresponding to port 8888. You will see entries like:

    -A ufw-user-input -p tcp --dport 8888 -j ACCEPT (for TCP)

    -A ufw-user-input -p udp --dport 8888 -j ACCEPT (for UDP)

### Use ufw show added

The ufw show added command displays
the rules as they were added, including the protocol (if specified).

Run:

    sudo ufw show added

Look for the rule for port 8888. If the protocol was
specified when the rule was added, it will appear here. For example:

    allow 8888/tcp (TCP only)

    allow 8888/udp (UDP only)

    allow 8888 (both TCP and UDP)

### Test the Rule

You can test the rule by attempting to connect to the port using both TCP and UDP protocols.

For example:

Test TCP:

    nc -zv <your-server-ip> 8888

Test UDP:

    nc -zuv <your-server-ip> 8888

### Re-add the Rule with Explicit Protocol

If you're unsure and want to ensure the rule is clear,
you can delete the ambiguous rule and re-add it with
the protocol explicitly specified.

For example:

    sudo ufw delete allow 8888
    sudo ufw allow 8888/tcp
    sudo ufw allow 8888/udp

Why Doesn't ufw status Show the Protocol?
When you add a rule without specifying a protocol
(e.g., sudo ufw allow 8888), ufw internally creates rules for both TCP and UDP.
However, the ufw status output does not explicitly show this,
which can lead to confusion.

### Best Practice

To avoid ambiguity, always specify the protocol when adding rules. For example:

Use

    sudo ufw allow 8888/tcp for TCP only.

Use

    sudo ufw allow 8888/udp for UDP only.

Use

    sudo ufw allow 8888

for both TCP and UDP (but be aware of the ambiguity in the status output).

This ensures clarity and makes it easier to manage your firewall rules.

## 6. Allow or Deny by service name:

If a service is recognized by ufw (e.g., OpenSSH, Apache, Nginx):

    sudo ufw allow 'OpenSSH'

or

    sudo ufw deny 'Apache'

## 7. Closing a Port to Outside (Inbound) Traffic

If you want to deny inbound access to a port (e.g., TCP port 8080), simply run:

    sudo ufw deny 8080/tcp

This ensures that external sources on that port are dropped or rejected,
depending on your default deny policy. You can verify the rule with:

    sudo ufw status

The status should show something like:

    8080/tcp    DENY Anywhere

## 8. Using ufw with Docker

Understanding the Docker and ufw interaction
By default, Docker manipulates iptables rules
directly to allow container traffic, often bypassing ufw.
Therefore, even if ufw says a port is blocked,
Docker might punch through at the iptables level.

To have Docker respect ufw rules consistently, you typically
have to modify ufw’s forwarding policy and a ufw config file.
The steps below show how to configure ufw so that it
correctly handles traffic destined for Docker containers.

### Steps to Make ufw and Docker Work Together

Allow Forwarding in UFW Configuration

Edit /etc/default/ufw:

    sudo vim /etc/default/ufw

Find the line DEFAULT_FORWARD_POLICY and set it to ACCEPT:

    DEFAULT_FORWARD_POLICY="ACCEPT"

Save and exit.

### Confirm IP forwarding is enabled at the kernel level

Make sure:

    sudo sysctl net.ipv4.ip_forward

shows net.ipv4.ip_forward=1. If not, edit /etc/sysctl.conf or a file in /etc/sysctl.d/ to set:

    net.ipv4.ip_forward=1

### Set UFW rules

    sudo ufw allow proto tcp from 172.18.0.0/16 to any port 8000

    sudo ufw allow proto tcp from 172.17.0.0/16 to any port 8000

to accept forwarding from docekr bridge networks.

## Allow Docker-Specific Forwarding in before.rules

Edit /etc/ufw/before.rules:

    sudo vim /etc/ufw/before.rules

Right after the \*filter line, you’ll likely see a section like this:

    *nat

    :POSTROUTING ACCEPT [0:0]
    -A POSTROUTING -s 172.17.0.0/16 ! -o docker0 -j MASQUERADE
    COMMIT

    *filter
    ...

If it’s missing, you may need to add the MASQUERADE rule.
The rule ensures traffic from Docker subnets is masqueraded properly.
Adjust the [-s 172.17.0.0/16] part to match the Docker
subnet if yours is different. For example,
if you have multiple Docker networks, you may need additional lines for each.
Reload ufw After making changes, reload ufw so it picks up the new rules:

    sudo ufw disable
    sudo ufw enable

or simply:

    sudo ufw reload

(Though toggling off/on is more certain to cleanly apply changes.)

Restart Docker

    sudo systemctl restart docker

This ensures Docker re-initializes the iptables rules in sync with ufw’s changes.

## Allowing a Specific Port for Docker Containers

If you run a container and publish a port to the host
(e.g., docker run -p 8080:80 mycontainer),
that means the host’s port 8080 is mapped to the container’s port 80.

To allow traffic from outside to the container,
you need a ufw allow rule on the host port:

    sudo ufw allow 8080/tcp

Now external clients hitting your server’s port 8080 can reach the container on port 80.

If you want to ensure that only internal traffic or
certain subnets can access your container, you can use
ufw’s from syntax. For example, to allow inbound on port
8080 only from a specific subnet (e.g., 192.168.1.0/24):

    sudo ufw allow from 192.168.1.0/24 to any port 8080 proto tcp

## Denying External Access to a Docker Container

If you have a container published on host port 8080,
and you want to close it to outside traffic, you can:

    sudo ufw deny 8080/tcp

Alternatively, if you only want it accessible from within the host
(e.g., for local development), you can avoid publishing
the port (no -p or -P) and only access it via localhost
from the host itself (through Docker’s bridging or a Docker network).
If no port is published, ufw won’t need to block it from the outside,
since the traffic isn’t exposed externally.

## Useful Commands and Tips

Check UFW Logs:

UFW logs can be viewed in the system log or via journalctl on
newer Ubuntu releases. For instance:

    sudo journalctl -u ufw

or

check /var/log/ufw.log if it exists (older setups).

### Enabling Logging:

    sudo ufw logging on

or more verbosely:

    sudo ufw logging high

This helps debug any issues or see what traffic is being blocked or allowed.

Double-Check IP Forwarding:
If forwarding is needed
(for containers or any NAT rule), ensure
IP forwarding is enabled in
/etc/sysctl.conf:

    net.ipv4.ip_forward=1

Then reload:

    sudo sysctl -p

Stay Aware of Docker Network Subnets:
Docker might create networks with subnets like
172.17.0.0/16, 172.18.0.0/16, or 192.168.0.0/16.
If you have multiple Docker networks or custom subnets,
you might need multiple MASQUERADE lines in /etc/ufw/before.rules.

## Summary of Steps

Install and enable ufw:

    sudo apt update
    sudo apt install ufw
    sudo ufw enable

Set sensible defaults:

    sudo ufw default deny incoming
    sudo ufw default allow outgoing

Allow/deny specific ports (e.g., allow SSH, deny HTTP, etc.):

    sudo ufw allow 22/tcp
    sudo ufw deny 80/tcp

Enable forwarding for Docker (edit /etc/default/ufw and /etc/ufw/before.rules), then:

    sudo ufw reload
    sudo systemctl restart docker

Allow/deny container traffic by controlling the host’s published ports:

    sudo ufw allow 8080/tcp
    sudo ufw deny 8080/tcp

Verify rules:

    sudo ufw status numbered

Check logs if something isn’t working:

    sudo ufw logging on
    sudo journalctl -u ufw

## Final Notes:

1. Always be careful when setting default policies
   (especially deny incoming) to avoid locking yourself out of SSH on a remote server.

2. Docker can override ufw’s iptables rules.
   Ensuring Docker respects ufw requires correct setup of forwarding
   rules and sometimes additional iptables lines.

3. For advanced or unusual setups, consider whether using iptables
   (or nftables) directly offers more granular control than ufw.

With this, you should have a solid understanding of how to configure ufw on Ubuntu,
close ports from outside access, and allow/deny traffic to Docker containers.
