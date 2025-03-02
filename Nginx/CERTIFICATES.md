### Issueing certificates from https://letsencrypt.org/

# Issue HTTPS Certificates using Certbot

## Lets encrypt certificates should be renewed every 90 days.

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

      or specify all domains

      % sudo certbot --nginx -d yourdomain.com -d www.yourdomain.com

      Cpecify location:

      % sudo certbot --nginx -d yourdomain.com -d www.yourdomain.com \
            --cert-path /path/to/your/folder/cert.pem \
            --key-path /path/to/your/folder/privkey.pem \
            --fullchain-path /path/to/your/folder/fullchain.pem

      or

      % sudo certbot --nginx -d yourdomain.com -d www.yourdomain.com --config-dir /path/to/your/folder

      Get Certificates for Docker container:

      % sudo certbot certonly --manual -d sethlab.net -d www.sethlab.net -d git.sethlab.net --config-dir ./cert

    6. Just issue certificates
    	% sudo certbot certonly --nginx

    7. Test automatic renewal

      If you used default location for certificates
    	% sudo certbot renew --dry-run

      If you used custom location for certificates,
      you need to create certificate update script on your own.

      Use command:

      % sudo certbot renew --config-dir /path/to/cert

      If you cannot or prefer not to run as root, you can override all directories so Certbot writes where you have permission. You must set --config-dir, --work-dir, and --logs-dir. For example:

      % certbot renew \
         --config-dir ./cert \
         --work-dir ./cert/work \
         --logs-dir ./cert/logs

      example of certificate renewal script:

      ```bash
      #!/bin/bash

      echo "Running renew-certs.sh at $(date)" >> ./cert/renew-certs.log

      certbot renew \
               --config-dir ./cert \
               --work-dir ./cert/work \
               --logs-dir ./cert/logs


      docker compose restart reverse_proxy

      echo "Finished renew-certs.sh at $(date)" >> /home/user/renew-certs.log
      ```

      and register it in the crontab.
      List all crontabs:

      % crontab -l

      add task to crontab

      % sudo crontab -e

      % 0 3 * * * certbot renew --config-dir /path/to/cert --post-hook "systemctl reload nginx"


    	The command to renew certbot is installed in one of the
    	following locations:

    	/etc/crontab/
    	/etc/cron.*/*
    	systemctl list-timers

# Custom certificates for testing purposes only

## CRT

1. Create key

   openssl genpkey -algorithm RSA -out localhost.key -aes256

2. Cretae certificate

   openssl req -new -key localhost.key -out localhost.csr

3. Sign cerificate

   openssl x509 -req -days 365 -in localhost.csr -signkey localhost.key -out localhost.crt

## PEM

1. Cretae key

   openssl genpkey -algorithm RSA -out key.pem -aes256 -pass pass:yourpassword

   or
   To use withouy "passphrase"
   openssl genpkey -algorithm RSA -out key.pem

2. Cretae Certificate Signing Request (CSR)

   openssl req -new -key key.pem -out request.csr

3. Issue self signed certificate

   openssl req -x509 -key key.pem -in request.csr -out cert.pem -days 365

## OPTIONAL

4. Issue a Certificate Signed by a CA (Optional)

If you want a CA-signed certificate, submit your CSR
to a Certificate Authority. The CA will
provide you with a certificate (cert.pem) and possibly a CA bundle (ca.pem).

Alternatively, if you want to act as your own CA:

Create a CA Private Key and Certificate

    openssl genpkey -algorithm RSA -out ca-key.pem
    openssl req -x509 -new -nodes -key ca-key.pem -sha256 -days 1825 -out ca-cert.pem

- Sign the CSR with Your CA

  openssl x509 -req -in request.csr -CA ca-cert.pem -CAkey ca-key.pem -CAcreateserial -out cert.pem -days 365 -sha256

5. Combine Certificates (if needed)

   cat cert.pem key.pem > fullchain.pem

6. Verify the Certificate

   openssl x509 -in cert.pem -text -noout

# Run ASGI with Hypercorn for Django

    hypercorn your-project-name.asgi:application --bind 0.0.0.0:8000 --certfile localhost.crt --keyfile localhost.key

# Run ASGI with Unicorn for Fast API

    uvicorn app:app --host 0.0.0.0 --port 8000 --ssl-keyfile=key.pem --ssl-certfile=cert.pem --http2

# Run WSGI with Gunicorn

    gunicorn myproject.wsgi:application \
    --bind 0.0.0.0:443 \
    --certfile=/path/to/your/certfile.pem \
    --keyfile=/path/to/your/keyfile.pem
