#!/bin/bash
sudo yum update -y
sudo yum install java -y
sudo mkdir -p /nps/apps/
sudo chown -R ec2-user:ec2-user /nps
cd /nps/apps
wget https://dlcdn.apache.org/tomcat/tomcat-9/v9.0.54/bin/apache-tomcat-9.0.54.zip --no-check-certificate
unzip apache-tomcat-9.0.54.zip -d /nps/apps/
ln -s /nps/apps/apache-tomcat-9.0.54 tomcat8080
sudo chown -R ec2-user:ec2-user /nps/
sudo chmod 755 tomcat8080/bin/*.sh

sudo cat > "/usr/lib/systemd/system/tomcat8080.service" <<EOL
[Unit]
Description=Apache Tomcat Web Application Container
After=syslog.target network.target
[Service]
Type=forking
WorkingDirectory=/nps/apps/tomcat8080/bin/
ExecStart=/nps/apps/tomcat8080/bin/startup.sh
ExecStop=/nps/apps/tomcat8080/bin/shutdown.sh
User=ec2-user
Group=ec2-user
RestartSec=10
Restart=always
[Install]
WantedBy=multi-user.target
EOL

sudo systemctl daemon-reload
sudo systemctl start tomcat8080
sudo systemctl enable tomcat8080


