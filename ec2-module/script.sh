# Installing dependencies.

sudo exec > >(tee -i /var/log/user-data.log)
sudo exec 2>&1

sudo apt-get update -y 

sudo apt-get install software-properties-common -y

sudo apt-get install docker -y && sudo apt-get install docker-compose -y
sudo usermod -aG docker $USER
sudo chmod 777 /var/run/docker.sock


mkdir WebServer && cd WebServer



git clone https://github.com/evershopcommerce/evershop.git

sleep 30


docker-compose up -d
sleep 45