# Install PostgreSQL
install_postgresql_96() { 
  add-apt-repository -y "deb http://apt.postgresql.org/pub/repos/apt/ xenial-pgdg main" > /dev/null 2>&1
  wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
  apt-get update > /dev/null 2>&1
  apt-get install -y postgresql-9.6 postgresql-contrib-9.6 > /dev/null 2>&1
  sudo -u postgres psql postgres -c "ALTER USER postgres WITH ENCRYPTED PASSWORD '123456';" > /dev/null 2>&1
  cp /etc/postgresql/9.6/main/postgresql.conf /etc/postgresql/9.6/main/postgresql.conf.ori
  cp /etc/postgresql/9.6/main/pg_hba.conf /etc/postgresql/9.6/main/pg_hba.conf.ori
  chown postgres:postgres /etc/postgresql/9.6/main/postgresql.conf.ori
  chown postgres:postgres /etc/postgresql/9.6/main/pg_hba.conf.ori
}
