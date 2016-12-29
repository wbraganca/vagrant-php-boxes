#!/usr/bin/env bash

# Load helpers
source /vagrant/scripts/helpers.sh

show_message "Restarting MySQL..."
service mysql restart &> /dev/null

show_message "Restarting Apache..."
service apache2 restart &> /dev/null
