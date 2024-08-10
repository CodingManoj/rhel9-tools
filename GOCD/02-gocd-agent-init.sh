#!/bin/bash 

stat() {
    if [ $1 -eq  0 ] ; then 
        echo -e "\e[32m - $2 - Success \e[0m" 
    else 
        echo -e "\e[31m - $2 Failure \e[0m" 
        exit 1
    fi 
}

dnf install java-17-openjdk.x86_64 -y  &>/tmp/gocd-agent.log
stat $? "Installing Java"

id gocd  &>>/tmp/gocd-agent.log
if [ $? -eq 0 ]; then
  kill -9 `ps -u gocd | grep -v PID | awk '{print $1}'` &>>/tmp/gocd-agent.log
  userdel -rf gocd
fi

useradd gocd  &>>/tmp/gocd-agent.log
stat $? "Adding GoCD user"

curl -L -o /tmp/go-agent-23.5.0-18179.zip https://download.gocd.org/binaries/23.5.0-18179/generic/go-agent-23.5.0-18179.zip &>>/tmp/gocd-agent.log
stat $? "Download GoCD zip File"

unzip  -o /tmp/go-agent-23.5.0-18179.zip -d /home/gocd/ &>>/tmp/gocd-agent.log && rm -f /tmp/go-agent-23.5.0-18179.zip
stat $? "Unzipping GoCD zip file"

chown -R gocd:gocd /home/gocd/go-agent-23.5.0  &>>/tmp/gocd-agent.log


echo '
[Unit]
Description=GoCD Server

[Service]
Type=forking
User=gocd
ExecStart=/home/gocd/go-agent-23.5.0/bin/go-agent start sysd
ExecStop=/home/gocd/go-agent-23.5.0/bin/go-agent stop sysd
KillMode=control-group
Environment=SYSTEMD_KILLMODE_WARNING=true

[Install]
WantedBy=multi-user.target

' >/etc/systemd/system/gocd-agent.service
stat $? "Setup systemd GoCD Agent Service file"

systemctl daemon-reload &>>/tmp/gocd-agent.log
systemctl enable gocd-agent &>>/tmp/gocd-agent.log
stat $? "Enable GoCD Agent Service"

systemctl start gocd-agent &>>/tmp/gocd-agent.log
stat $? "Start GoCD Agent Service"

echo -e "\n \n -> Open this file \e[1;33m/home/gocd/go-agent-23.5.0/wrapper-config/wrapper-properties.conf\e[0m & Update \e[1;33mwrapper.app.parameter.101\e[0m line and replace \e[1;31mlocalhost\e[0m with gocd server ip address and restart gocd-agent service"
echo -e "To restart service \e[1;33msystemctl restart gocd-agent\e[0m"