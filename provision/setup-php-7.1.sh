#!/usr/bin/env bash
export DEBIAN_FRONTEND=noninteractive

vagrant_user=$(echo "$1")

# Load scripts
source /vagrant/scripts/helpers.sh
source /vagrant/scripts/install-mysql.sh
source /vagrant/scripts/install-postgresql-9.6.sh
source /vagrant/scripts/install-imagick-3.4.sh
source /vagrant/scripts/install-composer-php.sh
source /vagrant/scripts/install-freetds.sh

# Load settings.yaml
eval $(parse_yaml /vagrant/config/settings-php71.yaml "config_")


# Configure timezone and locales
configure_timezone_and_locales() {
  echo "${config_timezone}" > /etc/timezone
  if [ ${config_box} = "ubuntu/xenial64" ]; then
    ln -fs "/usr/share/zoneinfo/${config_timezone}" /etc/localtime
  fi

  apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
  dpkg-reconfigure --frontend noninteractive tzdata
  export LANGUAGE=en_US.UTF-8
  export LANG=en_US.UTF-8
  export LC_ALL=en_US.UTF-8
  locale-gen en_US.UTF-8
  dpkg-reconfigure locales
}

add_ppa_repositories() {
  show_message "Adding ppa:git-core/ppa repository..."
  add-apt-repository -y ppa:git-core/ppa &>/dev/null

  show_message "Adding ppa:ondrej/php repository..."
  add-apt-repository ppa:ondrej/php > /dev/null 2>&1

  show_message "Adding yarn repository..."
  curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
  echo "deb http://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list

  # Update apt-get info.
  apt-get update &>/dev/null
}

# Install python properties
install_python_properties() {
  apt-get install -y python-software-properties software-properties-common &>/dev/null
  apt-get update &>/dev/null
}

not_installed() {
  dpkg -s "$1" 2>&1 | grep -q 'Version:'
  if [[ "$?" -eq 0 ]]; then
    apt-cache policy "$1" | grep 'Installed: (none)'
    return "$?"
  else
    return 0
  fi
}

print_pkg_info() {
  local pkg="$1"
  local pkg_version="$2"
  local space_count
  local pack_space_count
  local real_space

  space_count="$(( 20 - ${#pkg} ))" #11
  pack_space_count="$(( 30 - ${#pkg_version} ))"
  real_space="$(( space_count + pack_space_count + ${#pkg_version} ))"
  printf " * $pkg %${real_space}.${#pkg_version}s ${pkg_version}\n"
}

apt_package_install_list=()

apt_package_check_list=(
  # base packages
  build-essential
  git
  zip
  unzip
  ngrep
  curl
  make
  vim
  colordiff
  pkg-config
  libmagickwand-dev
  imagemagick
  g++
  nodejs
  zlib1g-dev
  libssl-dev
  libreadline-dev
  libyaml-dev
  libsqlite3-dev
  sqlite3
  libxml2-dev
  libcurl4-openssl-dev
  libffi-dev
  python3-dev
  libjpeg-dev
  libtiff5-dev
  libnotify-bin
  memcached

  # ntp service to keep clock current
  ntp

  # Req'd for i18n tools
  gettext

  # dos2unix
  # Allows conversion of DOS style line endings to something we'll have less
  # trouble with in Linux.
  dos2unix

  # nginx is installed as the default web server
  nginx

  # Base packages for php7.1.
  php7.1-fpm
  php7.1-cli

  # Common and dev packages for php
  php7.1-common
  php7.1-dev

  # Extra PHP modules that we find useful
  php7.1-bz2
  php7.1-curl
  php7.1-gd
  php7.1-imap
  php7.1-intl
  php7.1-json
  php7.1-ldap
  php7.1-mbstring
  php7.1-mcrypt
  php7.1-mysql
  php7.1-opcache
  php7.1-soap
  php7.1-sqlite3
  php7.1-xml
  php7.1-xmlrpc
  php7.1-zip
  php7.1-pgsql

  # PHP MSSQL
  php7.1-sybase

  # PHP Memcached
  php-memcached

  # Latex
  #texlive-full

  # Yarn (Fast, reliable, and secure dependency management).
  yarn
)

install_xdebug_to_php7() {
  wget --quiet -c "https://xdebug.org/files/xdebug-2.5.0.tgz"
  tar -xf xdebug-2.5.0.tgz
  cd xdebug-2.5.0/
  phpize > /dev/null 2>&1
  ./configure > /dev/null 2>&1
  make > /dev/null 2>&1
  make install > /dev/null 2>&1
  echo "zend_extension=xdebug.so" > /etc/php/7.1/mods-available/xdebug.ini

  # Enable Xdebug for php-fpm
  ln -sf /etc/php/7.1/mods-available/xdebug.ini /etc/php/7.1/fpm/conf.d/20-xdebug.ini

  # Enable Xdebug for php-cli
  ln -sf /etc/php/7.1/mods-available/xdebug.ini /etc/php/7.1/cli/conf.d/20-xdebug.ini

  cd -
  rm -rf xdebug-2.5.0.tgz xdebug-2.5.0
}

install_node_modules() {
  npm set progress=false
  npm install -g grunt-cli > /dev/null 2>&1
  npm install -g gulp-cli > /dev/null 2>&1
  npm install -g bower > /dev/null 2>&1
  npm install -g browser-sync > /dev/null 2>&1
  npm set progress=true
}

package_check() {
  local pkg
  local pkg_version

  for pkg in "${apt_package_check_list[@]}"; do
    if not_installed "${pkg}"; then
      echo " *" "$pkg" [not installed]
      apt_package_install_list+=($pkg)
    else
      pkg_version=$(dpkg -s "${pkg}" 2>&1 | grep 'Version:' | cut -d " " -f 2)
      print_pkg_info "$pkg" "$pkg_version"
    fi
  done
}

package_install() {
  package_check

  if [[ ${#apt_package_install_list[@]} = 0 ]]; then
    show_message "No apt packages to install"
  else
    # Install required packages
    show_message "Installing apt-get packages..."
    apt-get -y install ${apt_package_install_list[@]}

    # Remove unnecessary packages
    show_message "Removing unnecessary packages..."
    apt-get autoremove -y

    # Clean up apt caches
    apt-get clean
  fi

  # Install Composer if it is not yet available.
  if [[ ! -n "$(composer --version --no-ansi | grep 'Composer version')" ]]; then
    show_message "Installing Composer..."
    install_composer_php
  fi

  if [[ ! -n "$(php -m | grep 'imagick')" ]]; then
    show_message "Installing Imagick 3.4.3RC1 for PHP..."
    install_imagick_343RC1
    echo "extension=imagick.so" > /etc/php/7.1/fpm/conf.d/20-imagick.ini
    echo "extension=imagick.so" > /etc/php/7.1/cli/conf.d/20-imagick.ini
  fi

  if [[ ! -n "$(php -m | grep 'Xdebug')" ]]; then
    show_message "Installing Xdebug..."
    install_xdebug_to_php7
  fi

  show_message "Installing node modules..."
  install_node_modules

  if ! which mysql > /dev/null; then
    show_message "Installing MySQL 5.7..."
    install_mysql_57
  fi

  if ! which psql > /dev/null; then
    show_message "Installing PostgreSQL 9.6..."
    install_postgresql_96
  fi

  show_message "Installing FreeTDS..."
  install_freetds
}

show_message "Provisioning Box..."

# Retrieve the Nginx signing key from nginx.org
wget --quiet "http://nginx.org/keys/nginx_signing.key" -O- | apt-key add -

# Apply the nodejs signing key
apt-key adv --quiet --keyserver "hkp://keyserver.ubuntu.com:80" --recv-key C7917B12 2>&1 | grep "gpg:"
apt-key export C7917B12 | apt-key add -

# Apply the PHP signing key
apt-key adv --quiet --keyserver "hkp://keyserver.ubuntu.com:80" --recv-key E5267A6C 2>&1 | grep "gpg:"
apt-key export E5267A6C | apt-key add -

# nodejs
wget -qO- https://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add -
add-apt-repository -y https://deb.nodesource.com/node_6.x

show_message "Update packages list and upgrade system"
system_update

show_message "Creating 2GB swap space in /swapfile..."
create_swap

show_message "Configure timezone and locales"
configure_timezone_and_locales

show_message "Installing python properties"
install_python_properties

# Add ppa repositories
add_ppa_repositories

# install packages
package_install

echo "Provisioning VM PHP 7.1 complete"
