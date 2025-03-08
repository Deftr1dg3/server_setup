# Simple setup

<!-- ---------------------------- -->
<!-- ---------------------------- -->
<!-- ---------------------------- -->

### file "./config/gitlab.rb"

external_url 'http://git.sethlab.net/'

# GitLab ssh port:

gitlab_rails['gitlab_shell_ssh_port'] = 2222

# Default Theme (2 = Dark):

gitlab_rails['gitlab_default_theme'] = 2

<!-- ---------------------------- -->
<!-- ---------------------------- -->
<!-- ---------------------------- -->

# OPTIONS:

# Create file gitlab.rb

# External URL use HTTP if you run:

external_url 'http://gitlab.example.com'

# If you use SSL/TLS protocol, cetrificates should be provided

# Othervise it will work

nginx['ssl_certificate'] = "/etc/gitlab/ssl/git.sethlab.net.crt"
nginx['ssl_certificate_key'] = "/etc/gitlab/ssl/git.sethlab.net.key"

letsencrypt['enable'] = true
letsencrypt['contact_emails'] = ['your-email@example.com']

# GitLab ssh port:

gitlab_rails['gitlab_shell_ssh_port'] = 22

# Time Zone:

gitlab_rails['time_zone'] = 'UTC'

# Default Theme (2 = Dark):

gitlab_rails['gitlab_default_theme'] = 2

# Default Canary GitLab Version:

gitlab_rails['gitlab_default_canary'] = false

# User and File Permissions:

user['username'] = 'git'
user['group'] = 'git'

# Database Settings ---------------------------------------

# PostgreSQL:

gitlab_rails['db_adapter'] = 'postgresql'
gitlab_rails['db_encoding'] = 'unicode'
gitlab_rails['db_host'] = 'localhost'
gitlab_rails['db_port'] = 5432
gitlab_rails['db_username'] = 'gitlab'
gitlab_rails['db_password'] = 'password'
gitlab_rails['db_database'] = 'gitlabhq_production'

# Database Load Balancing:

gitlab_rails['db_load_balancing'] = { 'hosts' => ['primary.example.com', 'secondary.example.com'] }

# Redis Settings ---------------------------------------

gitlab_rails['redis_host'] = '127.0.0.1'
gitlab_rails['redis_port'] = 6379
gitlab_rails['redis_password'] = 'redis_password'

# Redis Sentinel:

gitlab_rails['redis_sentinels'] = [
{ 'host' => '127.0.0.1', 'port' => 26379 },
{ 'host' => '127.0.0.2', 'port' => 26379 }
]

# SMTP Email Settings

gitlab_rails['smtp_enable'] = true
gitlab_rails['smtp_address'] = 'smtp.example.com'
gitlab_rails['smtp_port'] = 587
gitlab_rails['smtp_user_name'] = 'user@example.com'
gitlab_rails['smtp_password'] = 'password'
gitlab_rails['smtp_domain'] = 'example.com'
gitlab_rails['smtp_authentication'] = 'login'
gitlab_rails['smtp_enable_starttls_auto'] = true
gitlab_rails['smtp_tls'] = false

# LDAP Authentication

gitlab_rails['ldap_enabled'] = true
gitlab_rails['ldap_servers'] = {
'main' => {
'label' => 'LDAP',
'host' => 'ldap.example.com',
'port' => 389,
'uid' => 'sAMAccountName',
'bind_dn' => 'CN=user,OU=Users,DC=example,DC=com',
'password' => 'password',
'encryption' => 'plain',
'verify_certificates' => true,
'base' => 'OU=Users,DC=example,DC=com'
}
}

# Object Storage for Uploads:

gitlab_rails['object_store']['enabled'] = true
gitlab_rails['object_store']['connection'] = {
'provider' => 'AWS',
'aws_access_key_id' => 'AWS_ACCESS_KEY_ID',
'aws_secret_access_key' => 'AWS_SECRET_ACCESS_KEY',
'region' => 'us-east-1'
}
gitlab_rails['object_store']['objects']['artifacts']['bucket'] = 'gitlab-artifacts'

# Backup Configuration:

gitlab_rails['backup_path'] = '/var/opt/gitlab/backups'
gitlab_rails['backup_archive_permissions'] = 0644
gitlab_rails['backup_keep_time'] = 604800
gitlab_rails['backup_upload_connection'] = {
'provider' => 'AWS',
'region' => 'us-east-1',
'aws_access_key_id' => 'AWS_ACCESS_KEY_ID',
'aws_secret_access_key' => 'AWS_SECRET_ACCESS_KEY'
}
gitlab_rails['backup_upload_remote_directory'] = 'gitlab-backups'

# Monitoring and Logging ---------------------------------------

# Prometheus:

prometheus['enable'] = true
prometheus['listen_address'] = 'localhost:9090'

# Grafana:

grafana['enable'] = true
grafana['admin_password'] = 'grafana_password'

# Logging:

gitlab_rails['log_level'] = 'info'
gitlab_rails['log_directory'] = '/var/log/gitlab'

# Advanced Settings ---------------------------------------

# Sidekiq:

sidekiq['concurrency'] = 25
sidekiq['shutdown_timeout'] = 4

# Puma:

puma['worker_processes'] = 2
puma['worker_timeout'] = 60

# Gitaly:

gitaly['listen_addr'] = 'unix:/var/opt/gitlab/gitaly/gitaly.socket'
gitaly['auth_token'] = 'gitaly_token'

# GitLab Pages:

pages_external_url 'http://pages.example.com'
gitlab_pages['enable'] = true

# Container Registry:

registry_external_url 'https://registry.example.com'
registry['enable'] = true

# Security Settings ---------------------------------------

# Two-Factor Authentication:

gitlab_rails['two_factor_grace_period'] = 48

# Rate Limiting:

gitlab_rails['rate_limit_requests_per_period'] = 100
gitlab_rails['rate_limit_period'] = 60

# SSH:

gitlab_rails['gitlab_shell_ssh_port'] = 22

# Performance Settings

# Unicorn Workers:

unicorn['worker_processes'] = 4

# Database Pool Size:

gitlab_rails['db_pool'] = 10

# Cache Settings:

gitlab_rails['cache_store'] = {
'type' => 'redis',
'redis' => {
'host' => 'localhost',
'port' => 6379
}
}

# Other Settings

# GitLab Shell:

gitlab_shell['ssh_port'] = 22

# Mattermost Integration:

mattermost_external_url 'https://mattermost.example.com'

# GitLab Email:

gitlab_rails['gitlab_email_from'] = 'gitlab@example.com'
gitlab_rails['gitlab_email_reply_to'] = 'noreply@example.com'

# Kubernetes Integration:

gitlab_rails['kubernetes_enabled'] = true
