#/!/bin/bash

sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl
sudo apt-get install -y libssl-dev libz-dev luarocks lua-socket python3-pip
sudo apt-get install -y vim
pip3 install  asyncio aiohttp
