#!/bin/sh
mkdir -p /data/nginx
chown www-data /data/nginx
cat > /etc/nginx/nginx.conf <<EOF
user www-data;
worker_processes 2;
pid /var/run/nginx.pid;
daemon off;
events {
  worker_connections 768;
}
http {
  sendfile on;
  tcp_nopush on;
  tcp_nodelay on;
  keepalive_timeout 65;
  types_hash_max_size 2048;
  include /etc/nginx/mime.types;
  default_type application/octet-stream;
  access_log /data/nginx/access.log;
  error_log /data/nginx/error.log;
  gzip on;
  gzip_disable "msie6";
  gzip_types text/plain text/css application/json application/x-javascript text/xml application/xml application/xml+rss text/javascript;
  include /etc/nginx/conf.d/*.conf;
  include /etc/nginx/sites-enabled/*;
}
EOF
cat > /etc/nginx/sites-available/default <<EOF
server {
  listen 127.0.0.1:3000;
  root /usr/share/nginx/www;
  location / {
    proxy_pass http://127.0.0.1:8000;
    proxy_set_header host \$Host;
  }
  location /media {
    alias /data/media;
    expires 30d;
  }
  location /static {
    alias /data/static;
    expires 30d;
  }
}
EOF
cat > /etc/supervisor/conf.d/nginx.conf <<EOF
[program:nginx]
command=/usr/sbin/nginx
stdout_logfile=/var/log/supervisor/%(program_name)s.log
stderr_logfile=/var/log/supervisor/%(program_name)s.log
autorestart=true
EOF
supervisorctl update
