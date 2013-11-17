#!/bin/bash
if [[ -n `pg_lsclusters -h`  ]]; then
  echo cluster exists
  exit 1
fi
dirname=/data/postgresql
while getopts d: option; do
  case $option
  in
    d) dirname=$OPTARG;;
  esac
done
if [[ $dirname != /* ]]; then
  echo absolute dir path required
  exit 1
fi
pg_createcluster -d $dirname 9.1 main
echo "local all all trust" > /etc/postgresql/9.1/main/pg_hba.conf
pg_ctlcluster 9.1 main start
createuser -U postgres -s root
pg_ctlcluster 9.1 main stop
cat > /etc/supervisor/conf.d/postgresql.conf <<EOF
[program:postgresql]
command=/usr/lib/postgresql/9.1/bin/postgres -D $dirname -c config_file=/etc/postgresql/9.1/main/postgresql.conf
stdout_logfile=/var/log/supervisor/%(program_name)s.log
stderr_logfile=/var/log/supervisor/%(program_name)s.log
autorestart=true
user=postgres
EOF
supervisorctl update
