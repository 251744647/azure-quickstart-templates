# Install MongoDB Replica Set

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2F251744647%2Fazure-quickstart-templates%2Fmaster%2Fmongodb-replica-set-centos%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="
http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fmongodb-replica-set-ubuntu%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>


This template deploys a MongoDB Replica Set on CentOS and enables Zabbix monitoring, and allows user to define the number of secondary nodes. The replica set has a primary node, 2 secondary nodes by default.

This template also allows you to input your existing zabbix server IP address to monitor these MongoDB nodes.

The replica set nodes are exposed on public IP addresses that you can access through SSH on the standard port, also mongodb port 27017 open.

The nodes are under the same subnet. The primary node ip is 10.0.0.240, the secondary nodes ip address start from 10.0.0.4. For example:

primary node ip: 10.0.0.240

secondary node 1 ip: 10.0.0.4

secondary node 2 ip: 10.0.0.5


After deployment, you can do below to verify if the replica set really works or not:

1 SSH connect to primary node, execute below

$mongo

rs.status()


2 upper rs.status() will show the replica set details. You can check the data replication status through below:

db. mycol.insert({"title":"MongoDB Overview"})

db.mycol.find()


3 SSH connect to secondary nodes, execute below

$mongo

db.getMongo().setSlaveOk()

show collections

db.mycol.find()


4 If db.mycol.find() command can show the result like primary node does, then means the replica set works.




##Known Limitations
- We expose all the nodes on public addresses so that you can access MongoDB service through internet directly.
- MongoDB suggests that the replica set has an odd number of voting members. So the number of secondary nodes is better to set to even number, like 2, 4 or 6, then plus the primary node, fill the requirement that the replica set has an odd number of voting members.
- A replica set can have up to 50 members, but only 7 voting members. So the maximum number of secondary nodes is 6.
- The replica set doesn't have arbiter nodes.