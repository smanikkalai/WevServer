# Installing dependencies.

exec > >(tee -i /var/log/user-data.log)
exec 2>&1

su -i

sudo apt-get update -y 

sudo apt-get install software-properties-common
sudo apt-get install docker && sudo apt-get install docker-compose
mkdir WerServer && cd WebServer
git clone https://github.com/evershopcommerce/evershop.git
sleep 30

docker-compose up -d 

sleep 30 

docker exec -it $(docker ps -q | awk 'NR==0') /bin/bash -c 'checking the containers'

npm run user:create -- --email "your email" --password "your password" --name "your name"
