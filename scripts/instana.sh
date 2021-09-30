!#/bin/sh
apt update -y
apt install apt-transport-https ca-certificates curl software-properties-common -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"
apt update -y
apt-cache policy docker-ce
apt install docker-ce -y
systemctl start docker
systemctl enable docker

wget -qO - "https://self-hosted.instana.io/signing_key.gpg" | apt-key add -
echo "deb [arch=amd64] https://self-hosted.instana.io/apt generic main" > /etc/apt/sources.list.d/instana-product.list
apt-get update
apt-get install instana-console

mkdir -p /instana/log/instana /instana/data /instana/traces /instana/cert /instana/metrics
