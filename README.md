**Steps to setup application on AWS**

Terraform Setup
1. Checkout repo on your local having terraform installed on it with your acess_key and secret_key configured. 
2. Execute the following from the terraform folder to setup the jenkins master node, slave node and application server.
- teeraform init
- terraform plan
- terraform apply --auto-approve

Jenkins Master Node Setup
1.The jenkins is hosted on a docker container and in order to get the inital password execute the following command
docker exec -it container_name /bin/cat /var/jenkins_home/secrets/initialAdminPassword
2. install the suggested plugins.
3. create first admin user as instructed


