#!/bin/bash

## Following code can help in setting up AMI in AWS for practice of DevOps Tools 
export PATH="/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/.local/bin:/root/bin"
## Common Functions 
curl -s https://raw.githubusercontent.com/CodingManoj/rhel9-tools/main/RHEL-9-AMI/scripts/common-funs.sh > /tmp/common.sh
source /tmp/common.sh
case $ELV in 
    el7) EPEL=https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm ;;
    el8) EPEL=https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm ;;
esac

## Check ROOT USER 
if [ $(id -u) -ne 0 ]; then 
    error "You should be a root/sudo user to perform this script"
    exit 1
fi

## Disabling SELINUX
sed -i -e '/^SELINUX/ c SELINUX=disabled' /etc/selinux/config

## Disable firewall 
systemctl disable firewalld &>/dev/null

## Remove cockpit message 
yum remove insights-client -y
rm -f /etc/motd.d/insights-client

## Perform OS Update
yum install vim https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm net-tools bind-utils sshpass jq git nmap telnet -y

## Fixing SSH timeouts
sed -i -e '/TCPKeepAlive/ c TCPKeepAlive no' -e '/ClientAliveInterval/ c ClientAliveInterval 10' -e '/ClientAliveCountMax/ c ClientAliveCountMax 240'  /etc/ssh/sshd_config

## Profile Environment
curl -s https://raw.githubusercontent.com/CodingManoj/rhel9-tools/main/RHEL-9-AMI/scripts/ps1.sh >  /etc/profile.d/ps1.sh
curl -s https://raw.githubusercontent.com/CodingManoj/rhel9-tools/main/RHEL-9-AMI/scripts/env.sh > /etc/profile.d/boot-env.sh
curl -s https://raw.githubusercontent.com/CodingManoj/rhel9-tools/main/RHEL-9-AMI/scripts/profile > /etc/profile
chmod +x /etc/profile /etc/profile.d/*

useradd ec2-user
mkdir -p /home/ec2-user/.ssh
chown ec2-user:ec2-user /home/ec2-user/.ssh
chmod 700 /home/ec2-user/.ssh

echo "@reboot passwd -u ec2-user" >>/var/spool/cron/root
chmod 600 /var/spool/cron/root

## Enable Password Logins
sed -i -e '/^PasswordAuthentication/ c PasswordAuthentication yes' -e '/^PermitRootLogin/ c PermitRootLogin yes' /etc/ssh/sshd_config /etc/ssh/sshd_config.d/50-cloud-init.conf


## Setup user passwords
ROOT_PASS="DevOps321"
CENTOS_PASS="DevOps321"

echo "echo $ROOT_PASS | passwd --stdin root"   >>/etc/rc.d/rc.local 
echo "echo $CENTOS_PASS | passwd --stdin ec2-user"   >>/etc/rc.d/rc.local
echo "sed -i -e 's/^ec2-user:!!/ec2-user:/' /etc/shadow" >>/etc/rc.d/rc.local
chmod +x /etc/rc.d/rc.local

echo
echo 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDC1WUdkMj2oGj6borVYrJSaZT+Nhx3EfGGoeHPWbTP7F0OLVdh5584QhFXz+WpXvT5S2uDsHT49lstZkYWAKVJVCgrPZzbBtRdiiXRpXNValsCZ73RZUyw6nSfo9L9gLcskVNOdTcHUyaOLlpImAMnp64X6NoxQVT0/4bX21wChQOqeoyyiZr3OD8+z7PrVHmQxTx2r4kIstnsUDsGJjD5tmewmeHd81V+cWugQ5Kmyf9ZgFIuCmLdl+3Qnf81WjMHaI0hKFgG23AyJ6P2sX4Lz2EBXFg2F7iWMDIKpMsd0h++1Q+fEzfcR6e5zcnSi8TRChq2D1JpEZCIaHWIxBNsmpO2z8VzAeSEDIG2MeiJURjUgnegeUUsvqU5ZaEEeh4U4W+IQ8EIb+/mfKk6oJN7s1iKX9E7rinpSApN5tHAeSfqKSbQHeSS5WEZiCBya/Hg8PknjGQ9D9NFDzSfs6OI1+ZwnTHtirnBxN8ufuYZvnWYhElYGQxnNmCyT+ts70c= ec2-user@ip-172-31-34-4.ec2.internal' > /home/ec2-user/.ssh/authorized_keys
echo 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC2MytX2MASz/SLfex0jzLOnF4iFkT64jmUXwoOfYssOLHV8idC9Wc6VU1qpXsqJtsihc3ESs9zJEwCgyt60Ih4lx+/KROUZbGGkj4fJmZ6V1bwK70mL66JUyw/q3qcGOWGANJcXl0xYdojZWYFQDZ15vpXCAlRputZ4CbcnYC1RM8zdIE30/n4S1Sl1RaetgFoJf07UBJyWuCisZEdwHUSLHsBuQz4WaxVov9TEaIQCd+WWoU7NEN+JL7qzxc95XfTvDgzy+jwWBIrLHhH3jXm4qby1QtIZuW+Xt3LpK02am+S8JCPiQJnmFX2dTpXo4bMxxd3BN1/2TVfODSNN3IswAecwICFDKz5VsD1fEiCFmcNeO62j/BDN9RBamBP2e2ktebOqCf+uF1S5HISsL+D/KxcQWuQtspKJ/aYQ9q27bzj/wOcmyaQsWsUJNonRzRfIgtVSK1wXk3ho3Mj5VM6iZPAEr7ivNk0PlObDYhtj9xug3ZYQ6KE/x1z+z5SuZ0= root@ip-172-31-36-42.ec2.internal' >> /root/.ssh/authorized_keys
curl -s https://raw.githubusercontent.com/CodingManoj/rhel9-tools/main/RHEL-9-AMI/scripts/id_rsa > /root/.ssh/id_rsa
chmod -R 700 /root/.ssh/id_rsa*
chmod -R 700 /home/ec2-user/.ssh/id_rsa*

sed -i -e 's/showfailed//' /etc/pam.d/postlogin
sed -i -e '4 i colorscheme desert' /etc/vimrc

echo 'ec2-user ALL=(ALL) NOPASSWD:ALL' >/etc/sudoers.d/ec2-user
chattr +i /etc/ssh/sshd_config /etc/ssh/sshd_config.d/50-cloud-init.conf /etc/sudoers.d/ec2-user

curl -s https://raw.githubusercontent.com/CodingManoj/rhel9-tools/main/RHEL-9-AMI/scripts/ssh_config > /etc/ssh/ssh_config.d/04-ssh-config.conf
curl -s https://raw.githubusercontent.com/CodingManoj/rhel9-tools/main/RHEL-9-AMI/scripts/motd > /etc/motd

## Create directory for journalctl failure
mkdir -p /var/log/journal
curl -L -o /tmp/install-snoopy.sh https://github.com/a2o/snoopy/raw/install/install/install-snoopy.sh
bash /tmp/install-snoopy.sh stable && rm -f /tmp/install-snoopy.sh

## Remove Amazon SSM & CFN
rpm -e amazon-ssm-agent
unlink /etc/init.d/cfn-hup

## Disable GPG Checks by default
sed -i -e '/gpgcheck/ c gpgcheck=0' /etc/dnf/dnf.conf

## Keep the logs clean.
echo ':programname, isequal, "systemd-sysv-generator" /var/log/sysv.log
:programname, isequal, "/usr/sbin/irqbalance" /var/log/irq.log
& stop' >/etc/rsyslog.d/01-sysv.conf

# Commands to /bin
curl -s https://raw.githubusercontent.com/CodingManoj/rhel9-tools/main/RHEL-9-AMI/scripts/set-hostname.sh > /bin/set-hostname
curl -s https://raw.githubusercontent.com/CodingManoj/rhel9-tools/main/RHEL-9-AMI/scripts/mysql_secure_installation  > /usr/sbin/mysql_secure_installation
chmod +x /bin/set-hostname /usr/sbin/mysql_secure_installation

# Install AWS CLI
cd /tmp
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip &>/dev/null
/tmp/aws/install
/usr/local/bin/aws --version || true

yum clean all &>/dev/null
rm -rf /var/lib/yum/*  /tmp/*
sed -i -e '/aws-hostname/ d' -e '$ a r /tmp/aws-hostname' /usr/lib/tmpfiles.d/tmp.conf

# Empty All log files
truncate -s 0 `find /var/log -type f |xargs`

rm -rf /tmp/*

echo "** Script Execution Completed **"