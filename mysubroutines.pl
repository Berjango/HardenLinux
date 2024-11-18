#!/usr/bin/perl

#Common subroutines to my security programs
#Author - Peter Wolf
#Date - 12-11-2024
#dougalite@gmail.com


open (fh, ">", "efw.log"); 

sub isblocked
{
shift;
($ip,$port)=split(":");
@ipparts=split(".".$ip);
foreach(@_){
    ($bip,$bits)=split("/");
    @bipparts=split(".".$bip);
    $blocked=1;
    for(my $i = 0; $i <= 3-$bits/8; $i++){
        if($ipparts[i]!=$bipparts[i]){
            $blocked=0;
        }
    }
    if($blocked){
        return(1);
    }
    }
    return(0);
}
sub blockipsto
{
		foreach(@_){
			`sudo ufw deny to $_`;
            print"Blocked to $_ ";
		print fh "blocked to $_\n";
		}


}

sub blockipsfrom
{
		foreach(@_){
			`sudo ufw deny from $_`;
            print"Blocked from $_ ";
		print fh "blocked from $_\n";
		}


}


sub containsipv4
{

	return($_=~/\d+\.\d+\.\d+\.\d+/);
}
close(fh);
1;
