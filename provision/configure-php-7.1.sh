#!/usr/bin/env bash
export DEBIAN_FRONTEND=noninteractive

# Load helpers
source /vagrant/scripts/helpers.sh

# Load settings
eval $(parse_yaml /vagrant/config/settings-php71.yaml "config_")


# PHP CLI
if [ ! -f "/vagrant/config/php-7.1/php-cli.ini" ]; then
  contents=$(< /vagrant/provision/templates/php-7.1/php-cli.ini)
  contents=$(echo "$contents" | sed -e "s@\$TIMEZONE@$config_timezone@g")
  echo "$contents" > /vagrant/config/php-7.1/php-cli.ini
fi
cp /vagrant/config/php-7.1/php-cli.ini /etc/php/7.1/cli/conf.d/99-custom.ini
chmod 644 /etc/php/7.1/cli/conf.d/99-custom.ini


# PHP FPM
if [ ! -f "/vagrant/config/php-7.1/php-fpm.ini" ]; then
  contents=$(< /vagrant/provision/templates/php-7.1/php-fpm.ini)
  contents=$(echo "$contents" | sed -e "s@\$TIMEZONE@$config_timezone@g")
  echo "$contents" > /vagrant/config/php-7.1/php-fpm.ini
fi
cp /vagrant/config/php-7.1/php-fpm.ini /etc/php/7.1/fpm/conf.d/99-custom.ini
chmod 644 /etc/php/7.1/fpm/conf.d/99-custom.ini


# nginx
if [ ! -f "/vagrant/config/php-7.1/nginx/nginx.conf" ]; then
  cp /vagrant/provision/templates/php-7.1/nginx/nginx.conf /vagrant/config/php-7.1/nginx/nginx.conf
  rm -rf /etc/nginx/nginx.conf
fi
cp /vagrant/config/php-7.1/nginx/nginx.conf /etc/nginx/nginx.conf
chmod 644 /etc/nginx/nginx.conf


# MySQL 5.7
if [ ! -f "/vagrant/config/mysql-5.7/custom.cnf" ]; then
  cp /vagrant/provision/templates/mysql-5.7/custom.cnf /vagrant/config/mysql-5.7/custom.cnf
fi
cp /vagrant/config/mysql-5.7/custom.cnf /etc/mysql/mysql.conf.d/z-custom.cnf
chmod 644 /etc/mysql/mysql.conf.d/z-custom.cnf


# PostgreSQL 9.6
if [ ! -f "/vagrant/config/postgresql-9.6/postgresql.conf" ]; then
  cp /vagrant/provision/templates/postgresql-9.6/postgresql.conf /vagrant/config/postgresql-9.6/postgresql.conf
fi
cp /vagrant/config/postgresql-9.6/postgresql.conf /etc/postgresql/9.6/main/postgresql.conf
chown postgres:postgres /etc/postgresql/9.6/main/postgresql.conf
chmod 644 /etc/postgresql/9.6/main/postgresql.conf

if [ ! -f "/vagrant/config/postgresql-9.6/pg_hba.conf" ]; then
  cp /vagrant/provision/templates/postgresql-9.6/pg_hba.conf /vagrant/config/postgresql-9.6/pg_hba.conf
fi
cp /vagrant/config/postgresql-9.6/pg_hba.conf /etc/postgresql/9.6/main/pg_hba.conf
chown postgres:postgres /etc/postgresql/9.6/main/pg_hba.conf
chmod 644 /etc/postgresql/9.6/main/pg_hba.conf


# FreeTDS
if [ ! -f "/vagrant/config/freetds/freetds.conf" ]; then
  cp /vagrant/provision/templates/freetds/freetds.conf /vagrant/config/freetds/freetds.conf
fi
cp /vagrant/config/freetds/freetds.conf /etc/freetds/freetds.conf
chmod 644 /etc/freetds/freetds.conf
