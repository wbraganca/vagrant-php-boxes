#!/bin/bash
export DEBIAN_FRONTEND=noninteractive

install_mysql_57() {
  wget --quiet -P /tmp http://dev.mysql.com/get/mysql-apt-config_0.8.2-1_all.deb

  debconf-set-selections <<< 'mysql-apt-config mysql-apt-config/select-router select none'
  debconf-set-selections <<< 'mysql-apt-config mysql-apt-config/select-connector-python select none'
  debconf-set-selections <<< 'mysql-apt-config mysql-apt-config/select-workbench select none'
  debconf-set-selections <<< 'mysql-apt-config mysql-apt-config/select-server select mysql-5.7'
  debconf-set-selections <<< 'mysql-apt-config mysql-apt-config/select-mysql-utilities select mysql-utilities-1.5'

  dpkg -i /tmp/mysql-apt-config_0.8.2-1_all.deb > /dev/null 2>&1
  apt-get update > /dev/null 2>&1

  debconf-set-selections <<< "mysql-community-server mysql-community-server/root-pass password ${config_mysql_root_password}"
  debconf-set-selections <<< "mysql-community-server mysql-community-server/re-root-pass password ${config_mysql_root_password}"

  apt-get install -y mysql-server > /dev/null 2>&1

  if [ ! -f "./config/mysql-5.7/custom.cnf" ]; then
    cp ./provision/templates/mysql-5.7/custom.cnf ./config/mysql-5.7/custom.cnf
  fi

  # Loads timezone tables
  mysql -uroot -p${config_mysql_root_password} -e "UPDATE mysql.user SET authentication_string=PASSWORD('${config_mysql_root_password}'), plugin='mysql_native_password' WHERE user='root' AND host='localhost';"
  mysql_tzinfo_to_sql /usr/share/zoneinfo | mysql --user=root --password=${config_mysql_root_password} --force mysql

  rm -rf /tmp/mysql-apt-config_0.8.2-1_all.deb

  service mysql restart &> /dev/null
  mysql -uroot -p${config_mysql_root_password} -e "GRANT ALL ON *.* TO root@'%' IDENTIFIED By '${config_mysql_root_password}';" &> /dev/null
  mysql -uroot -p${config_mysql_root_password} -e "FLUSH PRIVILEGES;" &> /dev/null
}

install_mysql_55() {
  debconf-set-selections <<< "mysql-server mysql-server/root_password password ${config_mysql_root_password}"
  debconf-set-selections <<< "mysql-server mysql-server/root_password_again password ${config_mysql_root_password}"
  apt-get install -y mysql-server-5.5 mysql-client-5.5 > /dev/null 2>&1
}

remove_mysql() {
  apt-get remove -y --purge mysql-server mysql-client mysql-common
  apt-get autoremove -y
  apt-get autoclean

  rm -rf /var/lib/mysql
  rm -rf /var/log/mysql
  rm -rf /etc/mysql
}
