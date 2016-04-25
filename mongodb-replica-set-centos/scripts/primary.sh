#!/bin/bash

replSetName=$1
secondaryNodes=$2
zabbixServer=$3


#create repo
cat > /etc/yum.repos.d/mongodb-org-3.2.repo <<EOF
[mongodb-org-3.2]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/redhat/\$releasever/mongodb-org/3.2/x86_64/
gpgcheck=0
enabled=1
EOF

#install
yum install -y mongodb-org

#ignore update
sed -i '$a exclude=mongodb-org,mongodb-org-server,mongodb-org-shell,mongodb-org-mongos,mongodb-org-tools' /etc/yum.conf

#disable selinux
sed -i '/^[^#]/s/\(SELINUX=\)\([a-z]\+\)/\1disabled/' /etc/sysconfig/selinux
setenforce 0

#kernel settings
if [[ -f /sys/kernel/mm/transparent_hugepage/enabled ]];then
echo never > /sys/kernel/mm/transparent_hugepage/enabled
fi
if [[ -f /sys/kernel/mm/transparent_hugepage/defrag ]];then
echo never > /sys/kernel/mm/transparent_hugepage/defrag
fi

#configure
sed -i 's/\(bindIp\)/#\1/' /etc/mongod.conf

#start replica set
mongod --dbpath /var/lib/mongo/ --replSet $replSetName --logpath /var/log/mongodb/mongod.log --fork





#install zabbix agent
cd /tmp
yum install -y gcc wget > /dev/null 
wget http://jaist.dl.sourceforge.net/project/zabbix/ZABBIX%20Latest%20Stable/2.2.5/zabbix-2.2.5.tar.gz > /dev/null
tar zxvf zabbix-2.2.5.tar.gz
cd zabbix-2.2.5
groupadd zabbix
useradd zabbix -g zabbix -s /sbin/nologin
mkdir -p /usr/local/zabbix
./configure --prefix=/usr/local/zabbix --enable-agent
make install > /dev/null
cp misc/init.d/fedora/core/zabbix_agentd /etc/init.d/
sed -i 's/BASEDIR=\/usr\/local/BASEDIR=\/usr\/local\/zabbix/g' /etc/init.d/zabbix_agentd
sed -i '$azabbix-agent    10050/tcp\nzabbix-agent    10050/udp' /etc/services
sed -i '/^LogFile/s/tmp/var\/log/' /usr/local/zabbix/etc/zabbix_agentd.conf
hostName=`hostname`
sed -i "s/^Hostname=Zabbix server/Hostname=$hostName/" /usr/local/zabbix/etc/zabbix_agentd.conf
if [[ $zabbixServer =~ ([0-9]{1,3}.){3}[0-9]{1,3} ]];then
sed -i "s/^Server=127.0.0.1/Server=$zabbixServer/" /usr/local/zabbix/etc/zabbix_agentd.conf
sed -i "s/^ServerActive=127.0.0.1/ServerActive=$zabbixServer/" /usr/local/zabbix/etc/zabbix_agentd.conf
sed -i "s/^Server=127.0.0.1/Server=$zabbixServer/" /usr/local/zabbix/etc/zabbix_agent.conf
fi
touch /var/log/zabbix_agentd.log
chown zabbix:zabbix /var/log/zabbix_agentd.log

#start zabbix agent
chkconfig --add zabbix_agentd
chkconfig zabbix_agentd on
/etc/init.d/zabbix_agentd start


#initiate replica set

#config ={_id:"$replSetName",members:[{_id:0,host:"10.0.0.240:27017"}]}

sleep 15
n=`ps -ef |grep -v grep|grep mongod |wc -l`
if [[ $n -eq 1 ]];then
echo "mongod started successfully"
else
echo "mongod started failed!"
fi

echo "starting initiating the replica set"
curl ifconfig.me > /tmp/ip.txt 2> /dev/null
publicIP=`cat /tmp/ip.txt`

mongo <<EOF
use admin
config ={_id:"$replSetName",members:[{_id:0,host:"$publicIP:27017"}]}
rs.initiate(config)
exit
EOF
if [[ $? -eq 0 ]];then
echo "replica set initiation succeeded."
else
echo "replica set initiation failed!"
fi


#add secondary nodes
for((i=1;i<=$secondaryNodes;i++))
do
let a=3+$i
mongo --eval "printjson(rs.add('10.0.0.${a}:27017'))"
if [[ $? -eq 0 ]];then
echo "adding server 10.0.0.${a} successfully"
else
echo "adding server 10.0.0.${a} failed!"
fi
done