#!/bin/sh

# This scripts brings the server boxes up, ensure that DNS, AD etc all synced up before installing workstations,
# However they should be able to install as soon as DC1 is fully operational.
echo -e "\e[1;32m - installing Servers\e[0m";
echo -e "\e[1;36m ... Installing DC1\e[0m";
vagrant up dc1
echo -e "\e[1;36m ... Give it a few minutes to sync and settle\e[0m";
sleep 300
echo -e "\e[1;36m ... Installing WEF Server\e[0m";
vagrant up wef
echo -e "\e[1;36m ... You can start installation of workstations on another server now!\e[0m";
echo -e "\e[1;36m ... Installing DC2\e[0m";
vagrant up dc2
