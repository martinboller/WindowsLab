#!/bin/sh

# This scripts brings the boxes up, adding a little wait between them to get DNS, AD etc all synced up
vagrant up dc1
sleep 30
vagrant up wef
sleep 30
vagrant up dc2
sleep 30
vagrant up win10a
sleep 30
vagrant up win10b