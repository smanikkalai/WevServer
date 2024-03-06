# Installing dependencies.

exec > >(tee -i /var/log/user-data.log)
exec 2>&1

sudo apt-get update -y 

sudo apt-get install software-properties-common

sudo apt-get install docker && apt-get install docker-compose
sudo usermod -aG docker $USER
sudo chmod 777 /var/run/docker.sock


mkdir WebServer && cd WebServer



git clone https://github.com/evershopcommerce/evershop.git

sleep 30


docker-compose up -d

sleep 45 