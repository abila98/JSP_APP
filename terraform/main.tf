provider "aws" {
  region = "us-east-2"
}


variable "subnet_prefix"{
  description = "cidr block for subnet"
#  default = "10.0.5.0/24"  #string
#  type = string

#  default = ["10.0.1.0/24", "10.0.3.0/24"] #list
#  type = list
}



resource "aws_vpc" "vpc-1" {
  cidr_block       = "10.0.0.0/16"
  tags = {
    Name = "vpc-1"
  }
}

resource "aws_subnet" "subnet-1" {
  vpc_id     = aws_vpc.vpc-1.id
  #cidr_block = var.subnet_prefix[0]  #passing varible
  cidr_block = var.subnet_prefix[0].cidr_block #passing
  availability_zone = "us-east-2b"
  tags = {
    Name = "subnet-1"
  }
}


resource "aws_internet_gateway" "ig-1" {
  vpc_id = aws_vpc.vpc-1.id

  tags = {
    Name = "ig-1"
  }
}

resource "aws_route_table" "rt-1" {
  vpc_id = aws_vpc.vpc-1.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ig-1.id
  }

  tags = {
    Name = "rt-1"
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.subnet-1.id
  route_table_id = aws_route_table.rt-1.id
}

resource "aws_security_group" "sg-1" {
  name        = "allow_web_traffic"
  description = "Allow inbound traffic"
  vpc_id      = aws_vpc.vpc-1.id

  ingress {
    description      = "HTTPS traffics"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  ingress {
    description      = "HTTP traffics"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

 ingress {
    description      = "SSH traffics"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
 
 ingress {
    description      = "Port 8080"
    from_port        = 8080
    to_port          = 8080
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
 

 ingress {
    description      = "Port 50000"
    from_port        = 50000
    to_port          = 50000
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }


  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "sg-1"
  }
}

resource "aws_network_interface" "ni-1" {
  subnet_id       = aws_subnet.subnet-1.id
  private_ips     = ["10.0.10.50"]
  security_groups = [aws_security_group.sg-1.id]
}


resource "aws_network_interface" "ni-2" {
  subnet_id       = aws_subnet.subnet-1.id
  private_ips     = ["10.0.10.60"]
  security_groups = [aws_security_group.sg-1.id]
}

resource "aws_network_interface" "ni-3" {
  subnet_id       = aws_subnet.subnet-1.id
  private_ips     = ["10.0.10.70"]
  security_groups = [aws_security_group.sg-1.id]
}


resource "aws_eip" "ep-1" {
  vpc      = true
  network_interface = aws_network_interface.ni-1.id
  associate_with_private_ip = "10.0.10.50"
  depends_on = [aws_internet_gateway.ig-1]
}


resource "aws_eip" "ep-2" {
  vpc      = true
  network_interface = aws_network_interface.ni-2.id
  associate_with_private_ip = "10.0.10.60"
  depends_on = [aws_internet_gateway.ig-1]
}

resource "aws_eip" "ep-3" {
  vpc      = true
  network_interface = aws_network_interface.ni-3.id
  associate_with_private_ip = "10.0.10.70"
  depends_on = [aws_internet_gateway.ig-1]
}


output "server_public_ip" {
  value = aws_eip.ep-1.public_ip
}

resource "aws_instance" "jenkins-master"{
  ami = "ami-0233c2d874b811deb"
 # subnet_id = aws_subnet.subnet-1.id
  key_name = "aws-key"
  instance_type = "t2.micro"
  
  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.ni-1.id
}
   user_data = <<-EOF
                #!/bin/bash
                yum update -y
                yum install docker -y
                usermod -a -G docker ec2-user
                ## Enable docker servic
                systemctl enable docker

                ## Start docker service
                systemctl start docker

                ## Check the Docker service.
                systemctl status docker
                docker run -u root --rm -d -p 8080:8080 -p 50000:50000 --name myjenkin -v jenkins-data:/var/jenkins_home -v /var/run/docker.sock:/var/run/docker.sock jenkinsci/blueocean
                EOF

  tags = {
    Name = "jenkins-master"
  }
}


resource "aws_instance" "jenkins-slave"{
  ami = "ami-0233c2d874b811deb"
 # subnet_id = aws_subnet.subnet-1.id
  key_name = "aws-key"
  instance_type = "t2.micro"

  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.ni-2.id
}
   user_data = <<-EOF
                #!/bin/bash
                yum update -y
                yum install git -y
                yum install ant -y
                amazon-linux-extras install ansible2 -y
                mkdir -p /nps/apps
                chown -R ec2-user:ec2-user /nps
                EOF

  tags = {
    Name = "jenkins-slave"
  }
}


resource "aws_instance" "application-server"{
  ami = "ami-0233c2d874b811deb"
 # subnet_id = aws_subnet.subnet-1.id
  key_name = "aws-key"
  instance_type = "t2.micro"

  network_interface {
  device_index         = 0
  network_interface_id = aws_network_interface.ni-3.id
}  
  user_data = "${file("install_tomcat.sh")}"


tags = {
    Name = "application-server"
  }
}



output "master_private_ip"{
  value = aws_instance.jenkins-master.private_ip
}
output "slave1_private_ip"{
  value = aws_instance.application-server.private_ip
}


