#!/bin/bash -e

#load environment variables
. env.sh

echo "Creating 2 namespace"
sudo ip netns add $NS1
sudo ip netns add $NS2

echo "Creating the veth pair -veth1 to veth2"
sudo ip link add veth10 type veth peer name veth11
sudo ip link add veth20 type veth peer name veth21

echo "Show links created. "
sudo ip link show type veth

echo "Adding veth  pairs rto the namespaces"
sudo ip link set veth11 netns $NS1
sudo ip link set veth21 netns $NS2

echo "Configuring the interface in the network namespace with an IP address."
sudo ip netns exec $NS1 ip addr add $IP1/24 dev veth11
sudo ip netns exec $NS2 ip addr add $IP2/24 dev veth21

echo "Enabling the interfaces inside the network namespaces"
sudo ip netns exec $NS1 ip link set dev veth11 up
sudo ip netns exec $NS2 ip link set dev veth21 up

echo "Creating the bridge for the 2 containers to communicate."
sudo ip link add name br0 type bridge

echo "Connecting the network namespace interfaces to the bridge"
sudo ip link set dev veth10 master br0
sudo ip link set dev veth20 master br0

echo "Assign ip address to the bridge named br0"
sudo ip addr add $BRIDGE_IP/24 br0

echo "Enabling the bridge."
sudo ip link set dev br0 up

echo "Enabling the interfaces connected to the bridge."
sudo ip link set dev veth10 up
sudo ip link set dev veth20 up

echo "Setting the loopback interfce in the network namespace."
sudo ip netns exec $NS1 ip link set lo up
sudo ip netns exec $NS2 ip link set lo up

echo "Setting the default route in the network namespaces."
sudo ip netns exec $NS1 ip route add default via $BRIDGE_IP dev veth11
sudo ip netns exec $NS2 ip route add default via $BRIDGE_IP dev veth21
