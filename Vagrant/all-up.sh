#!/bin/sh

# This scripts brings all the boxes up, adding a little wait between them to get DNS, AD etc all synced up
echo -e "\e[1;32m - installing Servers\e[0m";
echo -e "\e[1;36m ... Installing DC1\e[0m";
vagrant up dc1
echo -e "\e[1;36m ... Give it a few minutes to sync and settle\e[0m";
sleep 600
echo -e "\e[1;36m ... Installing WEF Server\e[0m";
vagrant up wef
echo -e "\e[1;36m ... You can start installation of workstations on another server now!\e[0m";
echo -e "\e[1;36m ... Installing DC2\e[0m";
vagrant up dc2
echo -e "\e[1;32m - installing Workstations\e[0m";
echo -e "\e[1;36m ... Installing WIN10A\e[0m";
vagrant up win10a
echo -e "\e[1;36m ... Installing WIN10B\e[0m";
vagrant up win10b
#echo -e "\e[1;36m ... Installing WIN11\e[0m";
#vagrant up win11
