#!/bin/bash

## Colors
R="\e[31m"
B="\e[34m"
Y="\e[33m"
G="\e[32m"
BU="\e[1;4m"
U="\e[4m"
IU="\e[7m"
LU="\e[2m"
N="\e[0m"

ELV=$(rpm -q basesystem |sed -e 's/\./ /g' |xargs -n 1|grep ^el)

## Common Functions

### Print Functions
hint() {
	echo -e "➜  Hint: $1$N"
}
info() {
	echo -e " $1$N"
}
Info() {
	echo -e "➜ INFO: $1$N"
}
Infot() {
	echo -e "\t➜ INFO: $1$N"
}
warning() {
	echo -e "${Y}☑  $1$N "
}
warningt() {
	echo -e "\t${Y}☑  $1$N "
}
success() {
	echo -e "${G}✓  $1$N"
}
successt() {
	echo -e "\t${G}✓  $1$N"
}
error() {
	echo -e "${R}✗  $1$N"
}
errort() {
	echo -e "\t${R}✗  $1$N"
}
head_bu() {
	echo -e "  $BU$1$N\n"
}

head_u() {
	echo -e "  $U$1$N\n"	
}

head_iu() {
	echo -e "  \t$IU$1$N\n"
}

head_lu() {
	echo -e "  $LU$1$N\n"
}

### Checking Root User or not
CheckRoot() {
LID=$(id -u)
if [ $LID -ne 0 ]; then 
	error "Your must be a root user to perform this command.."
	exit 1
fi
}

### Checking SELINUX
CheckSELinux() {
	STATUS=$(sestatus | grep 'SELinux status:'| awk '{print $NF}')
	if [ "$STATUS" != 'disabled' ]; then 
		error "SELINUX Enabled on the server, Hence cannot proceed. Please Disable it and run again.!!"
		hint "Probably you can run the following script to disable SELINUX"
		info "  curl -s https://raw.githubusercontent.com/indexit-devops/caput/master/vminit.sh | sudo bash"
		exit 1
	fi
}

CheckFirewall() {
	
	case $ELV in 
		el7|el8|el9)
			systemctl disable firewalld &>/dev/null
			systemctl stop firewalld &>/dev/null
		;;
		*)  error "OS Version not supported"
			exit 1
		;;
	esac
	success "Disabled FIREWALL Successfully"
}
