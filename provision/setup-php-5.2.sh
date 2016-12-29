#!/usr/bin/env bash
export DEBIAN_FRONTEND=noninteractive

vagrant_user=$(echo "$1")

# Load scripts
source /vagrant/scripts/helpers.sh
source /vagrant/scripts/install-mysql.sh

# Load settings.yaml
eval $(parse_yaml /vagrant/config/settings-php52.yaml "config_")

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
  libxslt1-dev
  libcurl4-openssl-dev
  libffi-dev
  python3-dev
  libjpeg-dev
  libtiff5-dev
  libnotify-bin
  memcached
  autoconf

  # ntp service to keep clock current
  ntp

  # Req'd for i18n tools
  gettext

  # dos2unix
  # Allows conversion of DOS style line endings to something we'll have less
  # trouble with in Linux.
  dos2unix

  # apache2 is installed as the default web server
  apache2

  # Yarn (Fast, reliable, and secure dependency management).
  yarn
)

install_php52() {
  rm -rf /tmp/php-5.2.17*
  cd /tmp

  apt-get install -y libxml2-dev \
libpcre3-dev \
libbz2-dev \
libcurl4-openssl-dev \
libjpeg-dev \
libpng12-dev \
libxpm-dev \
libfreetype6-dev \
libmysqlclient-dev \
libt1-dev \
libgd2-xpm-dev \
libgmp-dev \
libsasl2-dev \
libmhash-dev \
libpspell-dev \
libsnmp-dev \
libtidy-dev \
libxslt1-dev \
libmcrypt-dev \
libapache2-mod-fastcgi > /dev/null 2>&1

  mkdir /usr/include/freetype2/freetype
  ln -s /usr/include/freetype2/freetype.h /usr/include/freetype2/freetype/freetype.h

  wget --quiet -c -t 3 -O ./php-5.2.17.tar.gz http://museum.php.net/php5/php-5.2.17.tar.gz
  tar xvfz php-5.2.17.tar.gz
  cd php-5.2.17
  Patch PHP

  wget --quiet -c -t 3 -O ./libxml29_compat.patch https://mail.gnome.org/archives/xml/2012-August/txtbgxGXAvz4N.txt
  patch -p0 -b < libxml29_compat.patch

  wget --quiet -c -t 3 -O ./debian_patches_disable_SSLv2_for_openssl_1_0_0.patch https://bugs.php.net/patch-display.php\?bug_id\=54736\&patch\=debian_patches_disable_SSLv2_for_openssl_1_0_0.patch\&revision=1305414559\&download\=1
  patch -p1 -b < debian_patches_disable_SSLv2_for_openssl_1_0_0.patch

  wget --quiet -c -t 3 -O - http://php-fpm.org/downloads/php-5.2.17-fpm-0.5.14.diff.gz | gunzip > ./php-5.2.17-fpm-0.5.14.patch
  patch -p1 < php-5.2.17-fpm-0.5.14.patch

./configure \
  --prefix=/usr/share/php52 \
  --datadir=/usr/share/php52 \
  --mandir=/usr/share/man \
  --bindir=/usr/bin/php52 \
  --with-libdir=lib64 \
  --includedir=/usr/include \
  --sysconfdir=/etc/php52/apache2 \
  --with-config-file-path=/etc/php52/cli \
  --with-config-file-scan-dir=/etc/php52/conf.d \
  --localstatedir=/var \
  --with-pdo-mysql \
  --with-mysql-sock=/var/mysql/mysql.sock \
  --with-regex=php \
  --disable-posix \
  --with-pic \
  --with-layout=GNU \
  --with-pear=/usr/share/php \
  --enable-calendar \
  --enable-sysvsem \
  --enable-sysvshm \
  --enable-sysvmsg \
  --enable-bcmath \
  --with-bz2 \
  --enable-ctype \
  --without-gdbm \
  --with-iconv \
  --enable-exif \
  --enable-ftp \
  --enable-cli \
  --with-gettext \
  --enable-mbstring \
  --enable-shmop \
  --enable-sockets \
  --enable-wddx \
  --with-libxml-dir=/usr \
  --with-zlib \
  --with-kerberos=/usr \
  --with-openssl \
  --enable-soap \
  --enable-zip \
  --with-mhash \
  --without-mm \
  --with-curl \
  --with-zlib-dir=/usr \
  --with-xsl=shared,/usr \
  --with-xmlrpc=shared \
  --enable-force-cgi-redirect \
  --enable-fastcgi \
  --with-libdir=/lib/x86_64-linux-gnu \
  --enable-ipv6 \
  --with-mcrypt \
  --with-gd \
  --enable-gd-native-ttf \
  --with-xpm-dir \
  --with-jpeg-dir \
  --with-png-dir

  make
  make install

  mkdir /etc/php52/conf.d
  cp php.ini-recommended /etc/php52/apache2/php.ini

  a2enmod cgi fastcgi actions > /dev/null 2>&1
  a2enmod headers > /dev/null 2>&1
  a2enmod actions > /dev/null 2>&1
  a2enmod proxy_fcgi > /dev/null 2>&1
  a2enmod rewrite > /dev/null 2>&1
  a2enmod ssl > /dev/null 2>&1
  a2enmod vhost_alias > /dev/null 2>&1

  script_cgi="#!/bin/sh
PHPRC=\"/etc/php52/apache2/\"
export PHPRC
PHP_FCGI_CHILDREN=4
export PHP_FCGI_CHILDREN
PHP_FCGI_MAX_REQUESTS=5000
export PHP_FCGI_MAX_REQUESTS
exec /usr/bin/php52/php-cgi
"

  echo "$script_cgi" > "/usr/lib/cgi-bin/php52-cgi"
  chmod +x /usr/lib/cgi-bin/php52-cgi

  apache2_php52="# Include file for virtual hosts that need to run PHP 5.2

<FilesMatch \"\\.php\">
   SetHandler application/x-httpd-php5
</FilesMatch>

ScriptAlias /php52-cgi /usr/lib/cgi-bin/php52-cgi
Action application/x-httpd-php5 /php52-cgi
AddHandler application/x-httpd-php5 .php
"

  echo "$apache2_php52" > "/etc/apache2/php52.conf"

  add_line "Include php52.conf" "/etc/apache2/apache2.conf"
  rm -rf /tmp/php-5.2.17*

  ln -s /usr/bin/php52/php /usr/bin/php
}

install_node_modules() {
  npm set progress=false
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


  show_message "Installing node modules..."
  install_node_modules

  if ! which mysql > /dev/null; then
    show_message "Installing MySQL 5.5..."
    install_mysql_55
  fi

  show_message "Installing PHP 5.2.17..."
  install_php52
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

echo "Provisioning VM PHP 5.2 complete"
