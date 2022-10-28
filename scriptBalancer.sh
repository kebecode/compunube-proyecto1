#!/bin/bash
ipAdress=$1
echo "Instalando Consul"
wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install consul -y

echo "Ejecutando Consul en $ipAdress"
screen -dmS consul bash -c "consul agent -ui -bind=$ipAdress -client=0.0.0.0 -data-dir=."

sudo apt install haproxy -y
systemctl enable haproxy
cat <<EOT >> /etc/haproxy/haproxy.cfg
frontend stats
   bind *:1936
   mode http
   stats uri /
   stats show-legends
   no log

frontend http_front
   bind *:80
   default_backend http_back

backend http_back
    balance roundrobin
    server-template mywebapp 1-6 _mymicroservice._tcp.service.consul resolvers consul    resolve-opts allow-dup-ip resolve-prefer ipv4 check

resolvers consul
    nameserver consul 127.0.0.1:8600
    accepted_payload_size 8192
    hold valid 5s
EOT
sudo sed -i "s/No server is available to handle this request/Lo sentimos, no hay servidores web disponibles actualmente :(/g" /etc/haproxy/errors/503.http
sudo systemctl restart haproxy

echo "Instalando Artillery"
curl -sL https://deb.nodesource.com/setup_16.x | sudo -E bash -
sudo apt install nodejs -y
npm install -g artillery@latest