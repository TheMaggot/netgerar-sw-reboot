#!/bin/bash

# encrypt password by follwing command: 
# password=$(echo "this is a secret." | openssl enc -e -des3 -base64 -pass pass:mypasswd -pbkdf2)

# command line arguments
host=$1
password=$2

if [[ $# -ne 2 ]];
then
    echo "usage:"
    echo "./sw-reboot.sh <HOST> <ENCRYPTED_PASSWORD>"
    exit -1
fi

# place wher to store the cookie
cookie="/tmp/cookie.txt"

# netgear method of encrypting the password before sending it via POST to the webserver
function netgear_encrypt () {
    str1=$1
    str2=$2
    i1=0
    i2=0
    result=""

    while [ $i1 -lt ${#str1} -o $i2 -lt ${#str2} ]
    do
        if [ $i1 -lt ${#str1} ];
        then
            result="${result}${str1:$i1:1}"
            i1=$((i1+1))
        fi
        if [ $i2 -lt ${#str2} ];
        then
            result="${result}${str2:$i2:1}"
            i2=$((i2+1))
        fi
    done
    result=$(printf $result | md5sum | awk '{print $1}')
    echo $result
}

# grep value from HTML tag
function get_htmlvalue () {
    site=$1
    tag=$2
    cookie_arg=""
    if [ -f $cookie ];
    then
        cookie_arg="-b $cookie"
    fi
    value=`curl $cookie_arg -s http://$host/$site | grep $tag | sed -n -e "s/^.*value=['\"]\(.*\)['\"].*/\1/p"`
    echo $value
}

# decrypt password argument
pw_decr=`echo "${password}" | openssl enc -d -des3 -base64 -pass pass:mypasswd -pbkdf2`
# get rand value which is used to encrypt the password in netgear way
rand=$(get_htmlvalue "login.cgi" "rand")
# encrypt password
pw_ng_encr=$(netgear_encrypt $pw_decr $rand)
# login
curl -s --data-raw "password=$pw_ng_encr" -c $cookie http://$host/login.cgi > /dev/null

# get hash which is used to confirm reboot action
hash=$(get_htmlvalue "device_reboot.cgi" "hash")
# if .cgi is not available, try .htm
[[ -z "$hash" ]] && hash=$(get_htmlvalue "device_reboot.htm" "hash")

# let's go reboot
curl -s  --data-raw "CBox=on&hash=$hash" -b $cookie http://$host/device_reboot.cgi > /dev/null

# clean up
rm $cookie
