/* Modified by Peter Wolf 18-11-2024 to just slow down a CD/DVD drive 
For personal cyber security purposes. I have been running linux from DVD and hackers have been deliberately thrashing my optical drive.
This program is to slow down the optical drive so as to keep thrashing at a minimum.It would be very unwise and insecure to run linux from a USB drive
in my circumstances.An optical drive is a great inidicator of undesirable computer activity.*/



/* Setcd.c: Set various flags to control the behaviour of your cdrom device.
   (c) 1997 David A. van Leeuwen
   (c) 2004 Thomas Fritzsche <tf@noto.de>

   $Id: setcd.c,v 1.4 1999/08/24 19:07:34 david Exp $

     This program is free software; you can redistribute it and/or modify
     it under the terms of the GNU General Public License as published by
     the Free Software Foundation; either version 2 of the License, or
     (at your option) any later version.
     
     This program is distributed in the hope that it will be useful,
     but WITHOUT ANY WARRANTY; without even the implied warranty of
     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
     GNU General Public License for more details.
     
     You should have received a copy of the GNU General Public License
     along with this program; if not, write to the Free Software
     Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 */

#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <unistd.h>		/* lseek, read */
#include <string.h>		/* strncmp, memset */
#include <sys/ioctl.h>		/* ioctl */
#include <linux/cdrom.h>
#ifndef CDC_CLOSE_TRAY		/* moved into cdrom.h... */
#include <linux/ucdrom.h>
#endif
#include <linux/iso_fs.h>






int main(int ac, char ** av) 
{
     char * device = "/dev/cdrom";
     int fd, speed=1;
     extern int optind, optopt;
     extern char * optarg;


	  fd = open(device, O_RDONLY | O_NONBLOCK);
	  if (fd < 0) {
	       perror("Can't open device");
	       exit(-2);
	  } 

	       // patch to use SET STREAMING command
	       struct cdrom_generic_command cgc;
	       struct request_sense sense;
	       unsigned char buffer[28];
	       unsigned long rw_size;
	       memset(&cgc, 0, sizeof(cgc));
	       memset(&sense, 0, sizeof(sense));
	       memset(&buffer, 0, sizeof(buffer));
	       /* SET STREAMING command */ 
	       cgc.cmd[0] = 0xb6;
	       /* 28 byte parameter list length */
	       cgc.cmd[10] = 28;
	       cgc.sense = &sense;
	       cgc.buffer = buffer;
	       cgc.buflen = sizeof(buffer);
	       cgc.data_direction = CGC_DATA_WRITE;
	       cgc.quiet = 1;
	       if(speed == 0) {
		    /* set Restore Drive Defaults */  
		    buffer[0] = 4;
	       }
	       buffer[8] = 0xff;
	       buffer[9] = 0xff;
	       buffer[10] = 0xff;
	       buffer[11] = 0xff;
	       rw_size = 177 * speed;
	       /* read size */
	       buffer[12] = (rw_size >> 24) & 0xff;
	       buffer[13] = (rw_size >> 16) & 0xff;
	       buffer[14] = (rw_size >>  8) & 0xff;
	       buffer[15] = rw_size & 0xff;
	       /* read time 1 sec. */
	       buffer[18] = 0x03;
	       buffer[19] = 0xE8;
	       /* write size */
	       buffer[20] = (rw_size >> 24) & 0xff;
	       buffer[21] = (rw_size >> 16) & 0xff;
	       buffer[22] = (rw_size >>  8) & 0xff;
	       buffer[23] = rw_size & 0xff;
	       /* write time 1 sec. */
	       buffer[26] = 0x03;
	       buffer[27] = 0xE8;
	       if ((ioctl(fd, CDROM_SEND_PACKET, &cgc) != 0)
			 && (ioctl(fd, CDROM_SELECT_SPEED, speed) < 0)) {
		    perror("Failed to slow CD/DVD drive.\n");
		    exit(-1);
	       } else {
		    printf("Slowed down CD/DVD drive.\n");
	  }
	  close(fd);
     return 0;
}

/* compile-command: "gcc -Wall slowcd.c -o slowcd" 
may need to install libc6-dev first with "sudo apt install libc6-dev"*/
