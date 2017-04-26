# Vagrant Box
A custom Vagrant Box for PHP Web Development.


## Installation & Setup
```For Windows is recommended that you run the cmd window as Administrator```

1. Install Git
1. Install [VirtualBox >= 5.0.36](https://www.virtualbox.org/wiki/Downloads)
1. Install [Vagrant >= 1.9.3](https://www.vagrantup.com/downloads.html)
1. git clone https://github.com/wbraganca/vagrant-php-boxes vagrant-php-boxes
1. cd vagrant-php-boxes
1. install Vagrant plugins:
    * vagrant plugin install vagrant-hostsupdater
    * vagrant plugin install vagrant-vbguest (Optional)



### Box PHP 7.1.x
1. Copy the file `config/settings-php71.example.yaml` to `config/settings-php71.yaml` (change the settings as needed)
1. Copy the file `config/box.default.yaml` to `config/box.yaml` and set variable `vm: "php71"`
1. Run the `vagrant up` command in your terminal

```
Default Softwares
* Ubuntu 16.04 64-bit
* Git 2.x
* Nginx 1.10.x
* MySQL 5.7.x (root password: 123456)
* PostgreSQL 9.6.x (postgres password: 123456)
* Sqlite3
* FreeTDS
* Composer
* Node.js 6.x (With Yarn, Bower, Browsersync, Grunt, and Gulp)
* Memcached
```


### Box PHP 7.0.x
1. Copy the file `config/settings-php70.example.yaml` to `config/settings-php70.yaml` (change the settings as needed)
1. Copy the file `config/box.default.yaml` to `config/box.yaml` and set variable `vm: "php70"`
1. Run the `vagrant up` command in your terminal

```
Default Softwares
* Ubuntu 16.04 64-bit
* Git 2.x
* Nginx 1.10.x
* MySQL 5.7.x (root password: 123456)
* PostgreSQL 9.6.x (postgres password: 123456)
* Sqlite3
* FreeTDS
* Composer
* Node.js 6.x (With Yarn, Bower, Browsersync, Grunt, and Gulp)
* Memcached
```

### Box PHP 5.6.x
1. Copy the file `config/settings-php56.example.yaml` to `config/settings-php56.yaml` (change the settings as needed)
1. Copy the file `config/box.default.yaml` to `config/box.yaml` and set variable `vm: "php56"`
1. Run the `vagrant up` command in your terminal


```
Default Softwares
* Ubuntu 16.04 64-bit
* Git 2.x
* Nginx 1.10.x
* MySQL 5.7.x (root password: 123456)
* PostgreSQL 9.6.x (postgres password: 123456)
* Sqlite3
* FreeTDS
* Composer
* Node.js 6.x (With Yarn, Bower, Browsersync, Grunt, and Gulp)
* Memcached
```

### Box PHP 5.3.29
1. Copy the file `config/settings-php53.example.yaml` to `config/settings-php53.yaml` (change the settings as needed)
1. Copy the file `config/box.default.yaml` to `config/box.yaml` and set variable `vm: "php53"`
1. Run the `vagrant up` command in your terminal

```
Default Softwares
* Ubuntu 14.04 64-bit
* Git 2.x
* Apache 2.4
* MySQL 5.5.x (root password: 123456)
* Sqlite3
* Node.js 6.x (With Yarn, Bower, Browsersync, Grunt, and Gulp)
* Memcached
```

### Box PHP 5.2.17
1. Copy the file `config/settings-php52.example.yaml` to `config/settings-php52.yaml` (change the settings as needed)
1. Copy the file `config/box.default.yaml` to `config/box.yaml` and set variable `vm: "php52"`
1. Run the `vagrant up` command in your terminal

```
Default Softwares
* Ubuntu 14.04 64-bit
* Git 2.x
* Apache 2.4
* MySQL 5.5.x (root password: 123456)
* Sqlite3
* Node.js 6.x (With Yarn, Bower, Browsersync, Grunt, and Gulp)
* Memcached
```
