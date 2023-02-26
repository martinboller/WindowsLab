#!/bin/sh

# This scripts brings the server boxes up, ensure that DNS, AD etc all synced up before Starting workstations,
# However they should be able to install as soon as DC1 is fully operational.
echo -e "\e[1;32m - Starting Servers\e[0m";
echo -e "\e[1;36m ... Starting DC1\e[0m";
vagrant up dc1
echo -e "\e[1;36m ... Give it a few minutes to sync and settle\e[0m";
sleep 30
echo -e "\e[1;36m ... Starting WEF Server\e[0m";
vagrant up wef
echo -e "\e[1;36m ... You can start installation of workstations on another server now!\e[0m";
echo -e "\e[1;36m ... Starting DC2\e[0m";
vagrant up dc2
