#!/usr/bin/env bash

add_line() {
  LINE="$1"
  FILE="$2"
  grep -q "$LINE" "$FILE" || echo -e "\n${LINE}\n" >> "$FILE"
}

# Create the swap space 2GB
create_swap() {
  fallocate -l 2G /swapfile
  chmod 600 /swapfile
  mkswap /swapfile
  swapon /swapfile
  swapon -s
  echo "/swapfile   none    swap    sw    0   0" >> /etc/fstab
}

parse_yaml() {
   local prefix=$2
   local s='[[:space:]]*' w='[a-zA-Z0-9_]*' fs=$(echo @|tr @ '\034')
   sed -ne "s|^\($s\):|\1|" \
        -e "s|^\($s\)\($w\)$s:$s[\"']\(.*\)[\"']$s\$|\1$fs\2$fs\3|p" \
        -e "s|^\($s\)\($w\)$s:$s\(.*\)$s\$|\1$fs\2$fs\3|p"  $1 |
   awk -F$fs '{
      indent = length($1)/2;
      vname[indent] = $2;
      for (i in vname) {if (i > indent) {delete vname[i]}}
      if (length($3) > 0) {
         vn=""; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("_")}
         printf("%s%s%s=\"%s\"\n", "'$prefix'",vn, $2, $3);
      }
   }'
}

noroot() {
  sudo -EH -u "${vagrant_user}" "$@";
}

show_message() {
  echo " "
  echo "--> $1"
  echo " "
}

system_update() {
  apt-get update > /dev/null 2>&1
  apt-get upgrade -y > /dev/null 2>&1
  apt-get autoremove -y > /dev/null 2>&1
}

