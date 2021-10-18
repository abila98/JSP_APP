**Steps to setup application on AWS**

Terraform Setup
1. Checkout repo on your local having terraform installed on it with your acess_key and secret_key configured. 
2. Execute the following from the terraform folder to setup the jenkins master node, slave node and application server.
- teeraform init
- terraform plan
- terraform apply --auto-approve

Jenkins Master Node Setup
1. The jenkins is hosted on a docker container and in order to get the inital password execute the following command
docker exec -it container_name /bin/cat /var/jenkins_home/secrets/initialAdminPassword
2. install the suggested plugins.
3. create first admin user as instructed
4.

Jenkins Slave Node Setup
1. Place the aws-key.pem in the desired location and update the inventory accordingly.
2. Change the permission of the key accordingly.
3. In order to attach the slave node to master create the secret file and execte the java command from /nps/apps location
4.


Application can be viewed using the following URL.
http://<<application_server_ip>>:8080/jsp_app/index.html


WIP
