# Xray VPN

#### Try hip.hosting

#### Use "freemyip.com" for free domain name

## Technologies for circumventing censorship

1.  shadowsocks-2022

    Traffic masking, data that transferred throug shadowsocks does not look like
    any other data. (does not look like data transferred through VPN)

    But censors started to block every undefined data that ratio 0 / 1 in
    range 42.5% - 57%

    32nd USENIX Security Symposium

2.  VMESS

    VMess (V2Ray Messenger Protocol) is the original proprietary protocol used by V2Ray.

    It includes encryption and authentication to prevent detection and interference.
    Uses a UUID-based authentication system, making it more secure than traditional proxies.

    Can work with multiple transmission methods, such as TCP, WebSocket (WS), HTTP/2, mKCP, gRPC, and QUIC.

    More resource-intensive because it includes encryption.

    ✅ Pros:

    Secure with built-in encryption.
    Works well with obfuscation techniques.
    Supports multiple transport methods.
    ❌ Cons:

    Slightly higher latency due to encryption overhead.
    More detectable in some cases compared to VLESS.

3.  VLESS

    VLESS (V2Ray Lightweight and Efficient Secure Protocol) is a more lightweight alternative to VMess.

    No built-in encryption, meaning it relies on external protocols like TLS (HTTPS/SSL) for security.

    Uses a UUID-based authentication system (like VMess).

    Improves performance by reducing computational overhead (faster than VMess).

    Often used in XTLS (Xray TLS) for even better efficiency.

    ✅ Pros:

    Faster than VMess due to no built-in encryption.
    Better for TLS-based encryption (when combined with XTLS).
    Can be harder to detect when configured properly.
    ❌ Cons:

    Less secure if TLS is not used.

4.  XTLS/REALITY

    What is "Security: Reality" in V2Ray/3x-UI VPN?

    In the context of V2Ray, Xray, and 3x-UI VPN, "Reality" refers to a next-generation encryption and obfuscation mechanism used to enhance security and bypass censorship.

    🔹 What is Reality (REmote AUTHenticITY)?
    Reality (short for REmote AUTHenticITY) is an advanced security feature for VLESS.
    It improves stealth and security by making encrypted traffic appear like normal HTTPS traffic.
    It is a successor to XTLS (Xray TLS) and offers better resistance against deep packet inspection (DPI) and censorship.

    🔹 How Does Reality Work?
    TLS Spoofing: Instead of using a regular TLS certificate, Reality mimics legitimate HTTPS traffic (like Google, Cloudflare, etc.), making it harder for firewalls to detect.
    No Need for a Real Domain: Reality allows you to use fake or random domain names, eliminating the need for an actual TLS certificate.
    Encrypted Communication: Even though there is no traditional TLS handshake, Reality encrypts all data, preventing DPI attacks.
    Built-in Obfuscation: Unlike older protocols like VMess+TLS, Reality does not expose any fingerprintable characteristics, making it nearly undetectable.

    🔹 Why Use Reality?

    ✅ Better Performance – Unlike traditional TLS, Reality has lower latency and less overhead.
    ✅ Stronger Anti-Censorship – Firewalls cannot easily detect and block Reality traffic.
    ✅ No Need for Domain Verification – Unlike traditional TLS, it does not require a valid SSL certificate.
    ✅ Works Well with VLESS – Reality is typically used with VLESS+TCP or VLESS+gRPC.

## 3x-ui simulate regular browsing behaviour.

TLS handshake.

On active probbing ("Who are you?") request fom
cencors VPN server will redirect request to allowed website like "samsung.com".

VPN server can distinguish traficc from the "allowed" client and
trafic from the censor or ISP.

If the client is "allowd" the server will work as VPN, otherwise
the server will work like regular allowed website like "samsung.com"

https://github.com/XTLS/RealiTLScanner

# Setup

## DISABLE UFW (Uncomplicated Fire Wall) !!!.

### This VPN will use random port numbers for different connections.

### So firewall should be disabled.

1. INstall 3x-ui

link: https://github.com/MHSanaei/3x-ui

Command:

    sudo bash <(curl -Ls https://raw.githubusercontent.com/mhsanaei/3x-ui/master/install.sh)

    If does not work, use

    curl -Ls https://raw.githubusercontent.com/mhsanaei/3x-ui/master/install.sh | sudo bash

## After installation in Logs you will see credentials and server info:

#######
Username: psbSG7RwTF
Password: rvW0NnMbHD
Port: 7997
WebBasePath: ytSvmOfG6E1X0kP
Access URL: http://172.234.196.14:7997/ytSvmOfG6E1X0kP
#######

SAVE THEM!!!

## Manual:

┌───────────────────────────────────────────────────────┐
│ x-ui control menu usages (subcommands): │
│ │
│ x-ui - Admin Management Script │
│ x-ui start - Start │
│ x-ui stop - Stop │
│ x-ui restart - Restart │
│ x-ui status - Current Status │
│ x-ui settings - Current Settings │
│ x-ui enable - Enable Autostart on OS Startup │
│ x-ui disable - Disable Autostart on OS Startup │
│ x-ui log - Check logs │
│ x-ui banlog - Check Fail2ban ban logs │
│ x-ui update - Update │
│ x-ui legacy - legacy version │
│ x-ui install - Install │
│ x-ui uninstall - Uninstall │
└───────────────────────────────────────────────────────┘

## To get secure connection, use port forwarding:

ssh -L <LOCAL_HOST>:<LOCAL_PORT>:<REMOTE_HOST>:<REMOTE_PORT> -N -C -q -f

## Server Setup:

1. Login to the host

2. Got to "Inbounds"

3. Select "+ Add inbound"

4. In the modal window insert your actuall IP address:

   "Listen IP": <HOST_IP_ADDRESS>
   Is it is not set, the app will take IP from your
   browser (127.0.0.1) and it will not work.

5. Under "Security" section in modal window select:

   "Security": "Reality"

6. Under "Security/Reality" section in modal window press on
   "Get New Cert" at the bottom.
   (It creates security certificates)

7. Enable "Sniffing" option at the bottom.

8. Press create

### Will appear new inbound in the list.

## Connect from the client

1. Press in "+" on the left of inbound ID.

2. In modat window at the bottom you will see
   "URL" section and "connection string" in this section

   EXAMPLE:
   vless://8ec2057e-4b96-4015-8ecb-0e611b903276@172.234.196.14:37066?type=tcp&security=reality&pbk=zsUFUVDDM7peBNzwX2qxipURAlaqzGUNf50um2bUSDg&fp=chrome&sni=yahoo.com&sid=b3a6d3c84e5b&spx=%2F#obauc7ta

3. Check that the IP address (or domain) corresponds to the IP
   address of the Host server.

## Client Setup

Can be used several different client apps.
This time we will use Hiddify:

    https://github.com/hiddify/hiddify-app

Install on your devices.

On Mac OS don't forget to remove quarantine attrs.

    xattr -rc <FILE_NAME>

Then choose "+" and follow instructions.
