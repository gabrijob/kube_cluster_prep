#/!/bin/bash

# Post-installation steps
#sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
systemctl restart containerd

sudo service docker start

