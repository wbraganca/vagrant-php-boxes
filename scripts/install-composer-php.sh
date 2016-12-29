#!/usr/bin/env bash

install_composer_php() {
  curl -sS "https://getcomposer.org/installer" | php
  chmod +x "composer.phar"
  mv "composer.phar" "/usr/local/bin/composer"
}
