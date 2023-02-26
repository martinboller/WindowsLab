#!/bin/sh

# This scripts brings the workstation boxes up.
echo -e "\e[1;32m - Starting Workstations\e[0m";
echo -e "\e[1;36m ... Starting WIN10A\e[0m";
vagrant up win10a
echo -e "\e[1;36m ... Starting WIN10B\e[0m";
vagrant up win10b
#echo -e "\e[1;36m ... Starting WIN11\e[0m";
#vagrant up win11
