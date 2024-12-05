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


@newlyblocked=();
sub sortblocked   #populate second passed array with unique ips with source from the first passed array
{
($ref1,$ref2)=@_;
@newlyblocked=@$ref2;
foreach(@$ref1){
	if ( !inarray($_,@newlyblocked ) ){
		push(@newlyblocked,$_);
	}
}
return(@newlyblocked);
}






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
while(1){
$info=`ss -rt`;
if(length($info)<30){
$info=`netstat -t`;
}
my @blockedTO=();
my @blockedFROM=();

foreach (@blockedips){
	($TO,$FROM)=split("DENY IN");
    
	$TO =~ s/^\s*(.*?)\s*$/$1/; #removes spaces
	$FROM =~ s/^\s*(.*?)\s*$/$1/; #removes spaces
	if($TO=~/\d+\.\d+\.\d+\.\d+/){ #if contains ipv4
		push(@blockedTO,$TO);
	}
	if($FROM=~/\d+\.\d+\.\d+\.\d+/){#if contains  ipv4
		push(@blockedFROM,$FROM);
	}
}




#print "Blocked to = @blockedTO\n";


@badconnections=();

@connections=split(" ",$info);
foreach (@connections){
	if ($_=~/(\d+\.\d+\.\d+\.\d+)\:/){
	    if(!($_=~/.*192\.168\..*/)){
    		push(@badconnections,$1);
    		}
		}
	}
@badTO=();
@badFROM=();
$unblocked=0;
if (@badconnections){
    foreach (@badconnections){
#        $bad=$_;
#	($badip,$port)=split(":");
        if(!isblocked($_,@blockedTO)){
		    $unblocked+=1;
		    push(@badTO,$_);
        }
        if(!isblocked($_,@blockedFROM)){
 		    push(@badFROM,$_);
		    $unblocked+=1;
        }
    }



#print "blocked to = @blockedTO\n";
#print "blocked from = @blockedFROM\n";
	if($unblocked){
        blockipsto(@badTO);
        blockipsfrom(@badFROM);
		@newlyblocked=sortblocked(\@badTO,\@newlyblocked);
		@newlyblocked=sortblocked(\@badFROM,\@newlyblocked);
		$totalblockedips=$#newlyblocked+1;
        print "Total unique ips blocked this session = $totalblockedips\n";


	}

}
sleep(2);
}



