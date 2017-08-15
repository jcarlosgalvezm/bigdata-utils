#Prepair a cluster

host_name=$1

cm='192.168.1.120'
nodo1='192.168.1.121'
nodo2='192.168.1.122'
nodo3='192.168.1.123'
nodo4='192.168.1.124'

case $host_name in
        "cm") ip_addr=$cm;;
        "nodo1") ip_addr=$nodo1;;
        "nodo2") ip_addr=$nodo2;;
        "nodo3") ip_addr=$nodo3;;
        "nodo4") ip_addr=$nodo4;;
        *) echo 'ERROR: Unknown hostname'
           exit 0;;
esac

echo '# Generating the ssh directory...'
mkdir ~/.ssh/

echo '# Updating the system packages...'
yum update

packagelist='net-tools epel-release gcc'
groupslist=''

if [ $host_name == "cm" ]; then
        groupslist=$groupslist'"Development Tools" "X Window System" "Xfce"'
        packagelist=$packagelist' wget'
fi

yum groupinstall -y $groupslist
yum install -y $packagelist

if [ $host_name == "cm" ]; then
        echo '# Opening port 7180/tcp...'
        firewall-cmd --zone=public --add-port=7180/tcp --permanent
        firewall-cmd --reload
fi

echo '# Setting the hostname...'
hostname $host_name
echo $host_name > /etc/hostname

echo '# Setting the cluster hosts...'
echo -e "${cm}"   '             cm                              cm\n'\
"${nodo1}"'             nodo1.hdp.hadoop                nodo1\n'\
"${nodo2}"'             nodo2.hdp.hadoop                nodo2\n'\
"${nodo3}"'             nodo3.hdp.hadoop                nodo3\n'\
"${nodo4}"'             nodo4.hdp.hadoop                nodo4\n' > /etc/hosts

echo '# Setting a static ip address...'
sed -i -e 's/BOOTPROTO="dhcp"/BOOTPROTO="static"/g' /etc/sysconfig/network-scripts/ifcfg-enp0s3
echo -e 'IPADDR='"${ip_addr}"'\n'\
'NETMASK="255.255.255.0"\n'\
'GATEWAY="192.168.1.1"\n'\
'DNS1="8.8.8.8"' >> /etc/sysconfig/network-scripts/ifcfg-enp0s3

echo '# Restarting the network interface...'
systemctl restart network
