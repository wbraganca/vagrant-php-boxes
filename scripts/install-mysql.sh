#!/usr/bin/env bash

install_mysql_57() {
  wget --quiet -P /tmp http://dev.mysql.com/get/mysql-apt-config_0.8.1-1_all.deb

  debconf-set-selections <<< 'mysql-apt-config mysql-apt-config/select-router select none'
  debconf-set-selections <<< 'mysql-apt-config mysql-apt-config/select-connector-python select none'
  debconf-set-selections <<< 'mysql-apt-config mysql-apt-config/select-workbench select none'
  debconf-set-selections <<< 'mysql-apt-config mysql-apt-config/select-server select mysql-5.7'
  debconf-set-selections <<< 'mysql-apt-config mysql-apt-config/select-mysql-utilities select mysql-utilities-1.5'

  dpkg -i /tmp/mysql-apt-config_0.8.1-1_all.deb > /dev/null 2>&1
  apt-get update > /dev/null 2>&1

  debconf-set-selections <<< "mysql-community-server mysql-community-server/root-pass password 123456"
  debconf-set-selections <<< "mysql-community-server mysql-community-server/re-root-pass password 123456"

  apt-get install -y mysql-server > /dev/null 2>&1

  if [ ! -f "/vagrant/config/mysql-5.7/custom.cnf" ]; then
    cp /vagrant/provision/templates/mysql-5.7/custom.cnf /vagrant/config/mysql-5.7/custom.cnf
  fi

  # Loads timezone tables
  mysql -e "UPDATE mysql.user SET Host='%', plugin='mysql_native_password', authentication_string=password('123456') WHERE user='root';"
  mysql_tzinfo_to_sql /usr/share/zoneinfo | mysql --user=root --password=123456 --force mysql

  rm -rf /tmp/mysql-apt-config_0.8.1-1_all.deb

  service mysql restart &> /dev/null
  mysql -uroot -p123456 -e "GRANT ALL ON *.* TO root@'%' IDENTIFIED By '123456';" &> /dev/null
  mysql -uroot -p123456 -e "FLUSH PRIVILEGES;" &> /dev/null
}

install_mysql_55() {
  debconf-set-selections <<< "mysql-server mysql-server/root_password password 123456"
  debconf-set-selections <<< "mysql-server mysql-server/root_password_again password 123456"
  apt-get install -y mysql-server-5.5 mysql-client-5.5 > /dev/null 2>&1
}
