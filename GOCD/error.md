### Storage Fix

If you see an error saying disk space issue, mitigate using the following way:

Error :

```
	!!! GoCD Server's database is running on low disk space18 Aug, 2024 at 23:35:24 Local TimeGoCD has less than 1024M of disk space available to it.
		
    !!! GoCD Server's artifact repository is running low on disk space18 Aug, 2024 at 23:35:24 Local TimeGoCD has less than 1024M of disk space available to it

```

1) Ensure the selected server is t3.small and that has a minimum of 30gb disk 
2) If not, shutdown the server and increate the disk size to 30gb 
3) Start the server
4) sudo lsblk   ( This will list the block devices and block device with 30gb is our block device )
5) Now out of that parition 4 is the one that needs additional storage as it's under /home directory where our goCD is installed.
6) Increase the partition
``` sudo growpart /dev/nvme0n1 4```
7) Now 6xtend the volume of home to 6G from 1G

```
    $sudo lvextend -r -L +6G /dev/mapper/RootVG-homeVol
```

8) That's all, above error will be remidiated.