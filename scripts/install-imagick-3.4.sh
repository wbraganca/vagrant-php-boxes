#!/usr/bin/env bash

install_imagick_34() {
  cd /tmp
  wget --quiet "https://pecl.php.net/get/imagick-3.4.1.tgz"
  tar xvzf imagick-3.4.1.tgz
  cd imagick-3.4.1
  phpize > /dev/null 2>&1
  ./configure > /dev/null 2>&1
  make > /dev/null 2>&1
  make install > /dev/null 2>&1
  cd -
  rm -rf /tmp/imagick-3.4.1*
}

install_imagick_343RC1() {
  cd /tmp
  wget --quiet "https://pecl.php.net/get/imagick-3.4.3RC1.tgz"
  tar xvzf imagick-3.4.3RC1.tgz
  cd imagick-3.4.3RC1
  phpize > /dev/null 2>&1
  ./configure > /dev/null 2>&1
  make > /dev/null 2>&1
  make install > /dev/null 2>&1
  cd -
  rm -rf /tmp/imagick-3.4.3RC1*
}
