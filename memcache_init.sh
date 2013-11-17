#!/bin/bash
cat > /etc/supervisor/conf.d/memcached.conf <<EOF
[program:memcached]
command=/usr/bin/memcached -m 128 -u memcache
stdout_logfile=/var/log/supervisor/%(program_name)s.log
stderr_logfile=/var/log/supervisor/%(program_name)s.log
autorestart=true
EOF
supervisorctl update
