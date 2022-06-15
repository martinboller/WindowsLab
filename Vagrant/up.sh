#!/bin/sh

# This scripts delays the UP'ing of the boxes

#sleep 10
vagrant up dc1
sleep 30
vagrant up dc2
vagrant up wef
sleep 10
vagrant up win10a
sleep 10
vagrant up win10b
