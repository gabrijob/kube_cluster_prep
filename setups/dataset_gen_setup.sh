#/!/bin/bash

sudo apt-get update
sudo apt-get install -y default-jre default-jdk
sudo apt-get install -y libssl-dev libz-dev lua5.2 liblua5.2-dev luarocks
luarocks install luasocket
pip3 install requests asyncio aiohttp
