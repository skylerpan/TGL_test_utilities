#!/bin/sh
# Scripted from http://serverfault.com/questions/127636/force-local-ip-traffic-to-an-external-interface

DEV_0="wlp89s0"
DEV_1="eno1"
MAC_0=`nmcli device show ${DEV_0}|grep -i hw|awk '{print $2}'`
MAC_1=`nmcli device show ${DEV_1}|grep -i hw|awk '{print $2}'`
echo $MAC_0
echo $MAC_1

IP_0="192.168.100.1"
IP_1="192.168.101.1"
FAKE_0="192.168.102.1"
FAKE_1="192.168.103.1"

# Setup IP addresses
sudo ifconfig ${DEV_0} ${IP_0}/24
sudo ifconfig ${DEV_1} ${IP_1}/24

# nat source IP ${IP_0} -> ${IP_0} -> ${FAKE_0} when going to ${FAKE_1}
sudo iptables -t nat -A POSTROUTING -s ${IP_0} -d ${FAKE_1} -j SNAT --to-source ${FAKE_0}

# nat inbound ${FAKE_0} -> ${IP_0}
sudo iptables -t nat -A PREROUTING -d ${FAKE_0} -j DNAT --to-destination ${IP_0}

# nat source IP ${IP_1} -> ${FAKE_1} when going to ${FAKE_0}
sudo iptables -t nat -A POSTROUTING -s ${IP_1} -d ${FAKE_0} -j SNAT --to-source ${FAKE_1}

# nat inbound ${FAKE_1} -> ${IP_1}
sudo iptables -t nat -A PREROUTING -d ${FAKE_1} -j DNAT --to-destination ${IP_1}

sudo ip route add ${FAKE_1} dev ${DEV_0}
sudo arp -i ${DEV_0} -s ${FAKE_1} ${MAC_1}

sudo ip route add ${FAKE_0} dev ${DEV_1}
sudo arp -i ${DEV_1} -s ${FAKE_0} ${MAC_0}


echo "Server: iperf3 -B 192.168.101.1 -s"
echo "Client: iperf3 -B 192.168.100.1 -c 192.168.103.1 -t 60 -i 10"

iperf3 -B 192.168.101.1 -s & 
timeout 10 iperf3 -B 192.168.100.1 -c 192.168.103.1 -t 60 -i 10
timeout 10 iperf3 -B 192.168.100.1 -c 192.168.103.1 -t 60 -i 10 -R
killall iperf3
