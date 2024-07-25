#!/bin/bash

# Define the ssl_client_cert_1.pem block
read -r -d '' SSL_CLIENT_CERT_1 <<EOF
-----BEGIN CERTIFICATE-----

-----END CERTIFICATE-----
EOF

# Define the ssl_client_cert_2.pem block
read -r -d '' SSL_CLIENT_CERT_2 <<EOF
-----BEGIN CERTIFICATE-----

-----END CERTIFICATE-----
EOF

# Define the docker-compose.yml block
read -r -d '' DOCKER_COMPOSE <<EOF
services:
  marzban-node-1:
    # build: .
    image: gozargah/marzban-node:latest
    restart: always
    network_mode: host

    environment:
      SERVICE_PORT: 1000
      XRAY_API_PORT: 1001
      XRAY_EXECUTABLE_PATH: "/var/lib/marzban/xray-core/xray"
      XRAY_ASSETS_PATH: "/var/lib/marzban/xray-core/"
      SSL_CLIENT_CERT_FILE: "/var/lib/marzban-node/ssl_client_cert_1.pem"
      SERVICE_PROTOCOL: "rest"

    volumes:
      - /var/lib/marzban-node:/var/lib/marzban-node
      - /var/lib/marzban:/var/lib/marzban


  marzban-node-2:
    # build: .
    image: gozargah/marzban-node:latest
    restart: always
    network_mode: host

    environment:
      SERVICE_PORT: 2000
      XRAY_API_PORT: 2001
      XRAY_EXECUTABLE_PATH: "/var/lib/marzban/xray-core/xray"
      XRAY_ASSETS_PATH: "/var/lib/marzban/xray-core/"
      SSL_CLIENT_CERT_FILE: "/var/lib/marzban-node/ssl_client_cert_2.pem"
      SERVICE_PROTOCOL: "rest"

    volumes:
      - /var/lib/marzban-node:/var/lib/marzban-node
      - /var/lib/marzban:/var/lib/marzban
EOF

# Update package lists and 
sudo apt update

# Install Docker
curl -fsSL https://get.docker.com | sh >/dev/null

# install required packages
sudo apt update && sudo apt install -y curl socat git docker-compose unzip

# Clone the Marzban-node repository and create necessary directories
git clone https://github.com/Gozargah/Marzban-node
mkdir /var/lib/marzban-node

# Save SSL client certificates
echo "$SSL_CLIENT_CERT_1" | sudo tee /var/lib/marzban-node/ssl_client_cert_1.pem > /dev/null
echo "$SSL_CLIENT_CERT_2" | sudo tee /var/lib/marzban-node/ssl_client_cert_2.pem > /dev/null

# Create Docker Compose file
echo "$DOCKER_COMPOSE" | sudo tee /root/Marzban-node/docker-compose.yml > /dev/null

# Update xray-core
mkdir -p /var/lib/marzban/xray-core && cd /var/lib/marzban/xray-core
wget https://github.com/XTLS/xray-core/releases/latest/download/Xray-linux-64.zip
unzip Xray-linux-64.zip
rm Xray-linux-64.zip

# Add geoip.dat
wget -O /var/lib/marzban/xray-core/geoip.dat https://github.com/amotlagh/Marzban-node/raw/master/geoip.dat

# Start Marzban-node services
cd /root/Marzban-node
docker-compose up -d
