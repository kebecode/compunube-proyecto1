#!/bin/bash
ipAdress=$1
amountInstances=$2
consulLeader=$3
echo "Instalando Consul"
wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install consul -y

echo "Ejecutando Consul en $ipAdress"
screen -dmS consul bash -c "consul agent -server -retry-join=$consulLeader -bind=$ipAdress -data-dir=. -bootstrap-expect=2"

echo "Instalando Node.js y npm"
sudo apt install nodejs npm -y

echo "Instalando GIT"
sudo apt install git -y
echo "Clonando repo"
git clone https://github.com/omondragon/consulService
cd consulService/app
sudo sed -i "s/192.168.100.3/$ipAdress/g" index.js
npm install consul express

for ((i=1; i<=$amountInstances; i++))
do
  echo "Iniciando instancia $i"
  port=$((3000 + $i))
  app="web$port"
  screen -dmS $app bash -c "node index.js $port"
done
