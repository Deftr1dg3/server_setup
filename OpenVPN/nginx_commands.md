# NGINX

    1. Install
    	% sudo apt install nginx

    2. Create config file in
    	% cd /etc/nginx/sites-available

    	or use

    	/etc/nginx/nginx.conf

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
