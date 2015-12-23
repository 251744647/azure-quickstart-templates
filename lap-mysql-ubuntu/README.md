# Install a LAP node and another MYSQL node on Ubuntu Virtual Machines using Custom Script Linux Extension

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2F251744647%2Fazure-quickstart-templates%2Fmaster%2Flap-mysql-ubuntu%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

This template deploys a LAP node on an Ubuntu virtual machine and a MYSQL node on an additional VM. This template also provisions a storage account, virtual network, availability sets, public IP addresses and network interfaces required by the installation.


This template deploys a LAP node and a MYSQL node, will create simple info.php, mysql.php and remotemysql.php on LAP node to test if the deployment is successful or not.
The LAP node is exposed on a public IP address that you can access through a browser on port :80 as well as SSH on the standard port. 
The MYSQL node only has private ip address, the mysql database only allows to be accessed from LAP node.

##Known Issues and Limitations
- The template does not currently configure SSL on the nodes.
- The template uses username/password for provisioning and would ideally use an SSH key
- The deployment scripts are not currently idempotent and this template should only be used for provisioning new.