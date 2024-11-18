#!/usr/bin/perl


#NO GUARANTEE THIS PROGRAM DOES ANYTHING USEFUL. USE AT OWN RISK.

#Program to show suspected hacker connections.This is not 100% accurate but is useful.This program will produce both false positives and false negatives but they will
#hopefully be in the minority.I have used this technique to succesfully remove hackers from my computer but there is no guarantee that it will work for anyone else.

#This program uses and requires the ufw firewall which can be installed with "sudo apt install ufw". 

#Author - Peter Wolf
#Date - 12-11-2024
#dougalite@gmail.com
use FindBin;
use lib $FindBin::Bin;
require "mysubroutines.pl";

print "Checking for ufw\n";
my @blockedips=split("\n",`sudo ufw status verbose`);
if(!@blockedips){
	print"ERROR! ufw is not installed\n.You can exit the program (y=default) and install ufw with the following command  : \"sudo apt install ufw -y\"    or continue with limited functionality (n).\n";
	$choice = <STDIN>;
	chomp;
	if($_=~/y/){
	exit(1);
	}
	print("Continuing.\n");
}
else{
	print"ufw is installed\n";
	`sudo ufw enable`;
}
print "Finding bad connections.Please wait ,this can take a few minutes in some cases.\n";
#open my $handle, '<', "ipstoblock";
#chomp(my @blockedips = <$handle>);
#close $handle;

#print $connections;
#print @blockedips;

my @blockedTO=();
my @blockedFROM=();

foreach (@blockedips){
	#print "$_\n";
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
#print @blockedTO;
#print @blockedFROM;

@badconnections=();
$info=`ss -rt`;

@connections=split(" ",$info);
foreach (@connections){
	if ($_=~/(\d+\.\d+\.\d+\.\d+)\:/){
		push(@badconnections,$1);
		}
	}
@badTO=();
@badFROM=();
$unblocked=0;
if(@badconnections){
    foreach (@badconnections){
        $bad=$_;
        print $bad;
	($badip,$port)=split(":",$bad);
        if(isblocked($bad,@blockedTO)){
            print("    Blocked to");
        }
        else{
		$unblocked+=1;
		push(@badTO,$badip);
            print("     DANGER!!!!!!!!! NOT blocked to");
        }
        if(isblocked($bad,@blockedFROM)){
            print("    Blocked from\n");
        }
        else{
 		push(@badFROM,$badip);
		$unblocked+=1;
            print("     DANGER!!!!!!!!!!! NOT blocked from\n");
        }
    }
	if($unblocked){
	print("Do you want to block all the bad connections? (y/n)\n");
	$choice = <STDIN>;
	chomp $choice;
	if($choice=~/y/){
		foreach(@badTO){
			`sudo ufw deny to $_`;
		}

		foreach(@badFROM){
			`sudo ufw deny from $_`;
		}

	}
	}

}
else{
    print "No bad connections detected.\n";
}




