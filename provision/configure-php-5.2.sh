#!/usr/bin/env bash
export DEBIAN_FRONTEND=noninteractive

# Load helpers
source /vagrant/scripts/helpers.sh

# Load settings
eval $(parse_yaml /vagrant/config/settings-php52.yaml "config_")

# PHP
if [ ! -f "/vagrant/config/php-5.2/php-cli.ini" ]; then
  contents=$(< /vagrant/provision/templates/php-5.2/php-cli.ini)
  contents=$(echo "$contents" | sed -e "s@\$TIMEZONE@$config_timezone@g")
  echo "$contents" > /vagrant/config/php-5.2/php-cli.ini
fi
cp /vagrant/config/php-5.2/php-cli.ini /etc/php53/conf.d/99-custom.ini
chmod 644 /etc/php53/conf.d/99-custom.ini


# MySQL 5.5
if [ ! -f "/vagrant/config/mysql-5.5/custom.cnf" ]; then
  cp /vagrant/provision/templates/mysql-5.5/custom.cnf /vagrant/config/mysql-5.5/custom.cnf
fi
cp /vagrant/config/mysql-5.5/custom.cnf /etc/mysql/conf.d/z-custom.cnf
chmod 644 /etc/mysql/conf.d/z-custom.cnf
