 # Make sure the rool vol has minimum 30gb as disk
 
 ```
 # growpart /dev/nvme0n1 4 ; lvextend -l +80%FREE /dev/mapper/RootVG-varVol ; xfs_growfs /var
 # growpart /dev/nvme0n1 4 ; lvextend -l +100%FREE /dev/mapper/RootVG-homeVol ; xfs_growfs /home
 ```