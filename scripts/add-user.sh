#!/usr/bin/env bash

USERNAME=$1
FULLNAME=$2
EMAIL=$3
PASSWORD=$4
GITHUB_TOKEN=$5

if [ $(getent passwd $USERNAME) ] ; then
    echo "User '$USERNAME' already exists."
else
    # quietly add a user without password
    adduser -q --force-badname --disabled-password -shell /bin/bash --home "/home/$USERNAME/" --gecos "User" "$USERNAME" > /dev/null 2>&1

    # set password
    echo "$USERNAME:$PASSWORD" | chpasswd > /dev/null 2>&1

    # set groups 
    adduser $USERNAME ubuntu > /dev/null 2>&1
    adduser $USERNAME sudo > /dev/null 2>&1

    # set ssh-key
    sudo -H -u "$USERNAME" bash -c "mkdir -p \"/home/$USERNAME/.ssh\"" > /dev/null 2>&1
    chmod 700 "/home/$USERNAME/.ssh" > /dev/null 2>&1
    cd "/home/$USERNAME/.ssh"
    sudo -H -u "$USERNAME" bash -c "ssh-keygen -f \"id_rsa\" -t rsa -N '' -q"
    cd -

    # Configure Git
    sudo -H -u "$USERNAME" bash -c 'git config --global color.status auto'
    sudo -H -u "$USERNAME" bash -c 'git config --global color.branch auto'
    sudo -H -u "$USERNAME" bash -c 'git config --global color.interactive auto'
    sudo -H -u "$USERNAME" bash -c 'git config --global color.diff auto'
fi

# GitHub token
if [[ (-n ${GITHUB_TOKEN}) && (-n "$(composer --version --no-ansi | grep 'Composer version')") ]]; then
    sudo -H -u "$USERNAME" bash -c "composer config --global github-oauth.github.com $GITHUB_TOKEN"
fi

# Configure global user to Git
sudo -H -u "$USERNAME" bash -c "git config --global user.name \"${FULLNAME}\""
sudo -H -u "$USERNAME" bash -c "git config --global user.email $EMAIL"
