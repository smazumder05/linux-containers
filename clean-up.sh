#!/bin/bash

. env.sh

echo "Deleting the namespaces"
ip netns list | grep $NS1
if [ $? -eq 0 ]; then
    sudo ip netns delete $NS1
fi
ip netns list | grep $NS2
if [ $? -eq 0 ]; then
    sudo ip netns delete $NS2
fi

echo "Deleting the bridge"
sudo ip link delete br0
