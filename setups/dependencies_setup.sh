#/!/bin/bash

sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl lsb-release
sudo apt-get install -y libssl-dev libz-dev lua5.2 liblua5.2-dev luarocks python3-pip
luarocks install luasocket
sudo apt-get install -y vim
pip3 install  asyncio aiohttp
