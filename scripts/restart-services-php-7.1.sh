#!/usr/bin/env bash

# Load helpers
source /vagrant/scripts/helpers.sh

show_message "Restarting MySQL..."
service mysql restart &> /dev/null

show_message "Restarting PostgreSQL..."
service postgresql restart &> /dev/null

show_message "Restarting nginx..."
service nginx restart &> /dev/null

show_message "Restarting php7.1-fpm..."
service php7.1-fpm restart &> /dev/null
