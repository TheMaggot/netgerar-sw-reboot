# Netgear switch reboot script

This bash script reboots a Netgear GS*** switch via web interface. Tested and working fine with GS105Ev2 and GS108PEv3.

## Usage

`./sw-reboot.sh <HOST> <PASSWORD>`

### `<HOST>` 

The hostname or ip-address (if necessary, including webserver port), e.g. `192.168.0.5` or `192.168.0.5:8000`

### `<PASSWORD>` 

The Netgear login password, encrypted by the follwing command:
`echo $(echo "this is my password" | openssl enc -e -des3 -base64 -pass pass:mypasswd -pbkdf2)`
