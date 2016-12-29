#!/usr/bin/env bash

install_freetds() {
  apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* > /dev/null 2>&1
  apt-get -y autoremove > /dev/null 2>&1

  apt-get update > /dev/null 2>&1
  apt-get upgrade -y > /dev/null 2>&1
  apt-get autoremove -y > /dev/null 2>&1

  apt-get install -y freetds-dev freetds-bin tdsodbc > /dev/null 2>&1
}
