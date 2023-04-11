# VLAN and IP Route Management

This script allows you to create and delete VLANs and manage IP routes for a specific network interface. It requires root permissions to execute.

## Prerequisites

- iproute2 utilities

## Usage

1. Ensure the script is executable by running:

```sh
chmod +x vlan_manager.sh
```

2. Run the script with root permissions:
To create a VLAN and add IP routes:

```sh
sudo ./vlan_manager.sh create
```

To delete a VLAN and remove IP routes:


```sh
sudo ./vlan_manager.sh delete
```


The script will prompt you for necessary input values such as interface name, IP address, subnet, gateway, and VLAN ID during the create operation. The target network addresses should be provided in a text file with each address on a separate line.

When running the delete operation, the script will use the saved configuration from the previous create operation.
