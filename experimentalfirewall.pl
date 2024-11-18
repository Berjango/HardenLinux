#!/usr/bin/perl

#NO GUARANTEE THIS PROGRAM DOES ANYTHING USEFUL. USE AT OWN RISK.

#A firewall program based on ufw but that may change if ufw gets sabotaged.

#It is important to understand that this software is not professionally written.The aim is to produce something that roughly works and is useful because
#I have not found any free linux security software useful apart from ufw.This program works well for me but may not work for anyone else.

#License - free.

#Author - Peter Wolf
#Date - 14-11-2024
#dougalite@gmail.com

use FindBin;
use lib $FindBin::Bin;
require "mysubroutines.pl";


print "Checking for ufw\n";
my @blockedips=split("\n",`sudo ufw status verbose`);
if(!@blockedips){
	print"ERROR! ufw is not installed\n.Install ufw with the following command  : \"sudo apt install ufw -y\"   and run the program again.\n";
	exit(1);
}
else{
	print"ufw is installed\n";
	`sudo ufw enable`;
}
print "Experimental firewall is running! logfile = efw.log in the same directory as the program.\n";
$total_blocked=0;
$last_blocked="";
while(1){
$info=`ss -rt`;

my @blockedTO=();
my @blockedFROM=();

foreach (@blockedips){
	($TO,$FROM)=split("DENY IN");
    
	$TO =~ s/^\s*(.*?)\s*$/$1/;
	$FROM =~ s/^\s*(.*?)\s*$/$1/;
	if(containsipv4($TO)){
		push(@blockedTO,$TO);
	}
	if(containsipv4($FROM)){
		push(@blockedFROM,$FROM);
	}
}

@badconnections=();

@connections=split(" ",$info);
foreach (@connections){
	if ($_=~/(\d+\.\d+\.\d+\.\d+\:)/){
		push(@badconnections,$_);
		}
	}
@badTO=();
@badFROM=();
$unblocked=0;
if (@badconnections){
    foreach (@badconnections){
        $bad=$_;
	($badip,$port)=split(":");
        if(!isblocked($bad,@blockedTO)){
		    $unblocked+=1;
		    push(@badTO,$badip);
        }
        if(!isblocked($bad,@blockedFROM)){
 		    push(@badFROM,$badip);
		    $unblocked+=1;
        }
    }
	if($unblocked){
        blockipsto(@badTO);
        blockipsfrom(@badFROM);
        $just_blocked=pop(@badTO);
        if ($last_blocked!=$_){
            $total_blocked+=$unblocked;
            print "Total blocked ips = $total_blocked\n";
            $last_blocked=$just_blocked;
        }


	}

}
sleep(2);
}



