#!/bin/bash

if [ "$EUID" -ne 0 ]; then
  echo "Error: Please run this script with root permissions."
  exit 1
fi

config_file=".vlan_config"

create_vlan() {
  local ethnum=$1
  local ethaddr=$2
  local ethvlan=$3
  local targets_file=$4

  ip link add link $ethnum name $ethnum.$ethvlan type vlan id $ethvlan
  ip address add $ethaddr dev $ethnum.$ethvlan
  ip link set $ethnum up
  ip link set $ethnum.$ethvlan up

  echo "ethnum=$ethnum" > $config_file
  echo "ethaddr=$ethaddr" >> $config_file
  echo "ethvlan=$ethvlan" >> $config_file
  echo "targets_file=$targets_file" >> $config_file
}

delete_vlan() {
  local ethnum=$1
  local ethaddr=$2
  local ethvlan=$3

  ip address delete $ethaddr dev $ethnum.$ethvlan
  ip link delete dev $ethnum.$ethvlan

  rm -f $config_file
}

add_ip_routes() {
  local ethgw=$1
  local targets_file=$2

  while read -r ethtarget; do
    ip route add $ethtarget via $ethgw
  done < $targets_file
}

del_ip_routes() {
  local targets_file=$1

  while read -r ethtarget; do
    ip route del $ethtarget
  done < $targets_file
}

prompt_user() {
  read -p "Enter the Ethernet interface number (e.g., eth1): " ethnum
  read -p "Enter the IP address and subnet (e.g., 10.227.3.240/24): " ethaddr
  read -p "Enter the gateway IP address (e.g., 10.227.3.1): " ethgw
  read -p "Enter the VLAN ID (e.g., 1003): " ethvlan
  read -p "Enter the path to the target networks file (e.g., targets.txt): " targets_file
}

main() {
  if [ "$1" == "create" ]; then
    prompt_user
    create_vlan $ethnum $ethaddr $ethvlan $targets_file
    add_ip_routes $ethgw $targets_file
  elif [ "$1" == "delete" ]; then
    if [ -f $config_file ]; then
      source $config_file
      del_ip_routes $targets_file
      delete_vlan $ethnum $ethaddr $ethvlan
    else
      echo "Error: Configuration file not found. Please run 'create' before 'delete'."
      exit 1
    fi
  else
    echo "Usage: $0 {create|delete}"
    exit 1
  fi
}

main "$@"


