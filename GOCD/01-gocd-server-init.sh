#!/bin/bash 

stat() {
    if [ $1 -eq  0 ] ; then 
        echo -e "\e[32m - $2 - Success \e[0m" 
    else 
        echo -e "\e[31m - $2 Failure \e[0m" 
        exit 1
    fi 
}

dnf install java-17-openjdk.x86_64 -y  &>/tmp/gocd-server.log
stat $? "Install Java"

id gocd  &>>/tmp/gocd-agent.log
if [ $? -eq 0 ]; then
  kill -9 `ps -u gocd | grep -v PID | awk '{print $1}'` &>>/tmp/gocd-agent.log
  userdel -rf gocd
fi
useradd gocd  &>>/tmp/gocd-agent.log
stat $? "Adding GoCD user"

curl -L -o /tmp/go-server-23.5.0-18179.zip  https://download.gocd.org/binaries/23.5.0-18179/generic/go-server-23.5.0-18179.zip &>>/tmp/gocd-server.log
stat $? "Download GoCD zip File"

unzip  -o /tmp/go-server-23.5.0-18179.zip -d /home/gocd/ &>>/tmp/gocd-server.log && rm -f /tmp/go-server-23.5.0-18179.zip
stat $? "Unzipping GoCD zip file"

chown -R gocd:gocd /home/gocd/go-server-23.5.0  &>>/tmp/gocd-server.log

echo '
[Unit]
Description=GoCD Server

[Service]
Type=forking
User=gocd
ExecStart=/home/gocd/go-server-23.5.0/bin/go-server start sysd
ExecStop=/home/gocd/go-server-23.5.0/bin/go-server stop sysd
KillMode=control-group
Environment=SYSTEMD_KILLMODE_WARNING=true

[Install]
WantedBy=multi-user.target

' >/etc/systemd/system/gocd-server.service
stat $? "Setup systemd GoCD Service file"

systemctl daemon-reload &>>/tmp/gocd-server.log
stat $? "Load the Service"

systemctl enable gocd-server &>>/tmp/gocd-server.log
stat $? "Enable GoCD Service"

systemctl start gocd-server &>>/tmp/gocd-server.log
stat $? "Start GoCD Service"

echo -e "Open this URL -> http://$(curl -s ifconfig.me):8153"