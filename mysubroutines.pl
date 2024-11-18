#!/usr/bin/perl

#Soubroutine required by some programs to determine if a connection is blocked or not
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
sub blockips
{
		foreach(@_){
			`sudo ufw deny to $_`;
            print"Blocked to $_ ";
		print fh "$_\n";
		}


}

sub containsipv4
{

	return($_=~/\d+\.\d+\.\d+\.\d+/);
}
close(fh);
1;
