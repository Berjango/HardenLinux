#!/usr/bin/perl


#Program to show current network interface on linux
#Author - Peter Wolf
#21-10-2024
#dougalite@gmail.com



$currentinterface=`ip route`;

$currentinterface=~s/.*dev\s(\w*)\s.*/$1/;

print $1;
