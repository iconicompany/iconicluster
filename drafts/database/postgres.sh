# allow listen on all interfaces
echo "host    all             all             10.0.0.0/8              scram-sha-256" | sudo tee -a /etc/postgresql/14/main/pg_hba.conf
sudo sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/" /etc/postgresql/14/main/postgresql.conf
sudo service postgresql restart
