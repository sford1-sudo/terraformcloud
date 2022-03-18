
provider "aws" {
  region  = "us-east-1"
}

# VPC
resource "aws_vpc" "tf-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "tf-vpc"
  }
}
# subnet
resource "aws_subnet" "tf-subnet" {
  vpc_id     = aws_vpc.tf-vpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "tf-subnet"
  }
}
# security group !!!!!!!!!!REDO ME!!!!!!!!!
resource "aws_security_group" "tf-sg" {
  name        = "tf-sg"
  description = "Allow port 80 and 22 inbound traffic and all outbound"
  vpc_id      = aws_vpc.tf-vpc.id

  ingress {
    description = "port 22"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.tf-vpc.cidr_block]
  }
  ingress {
    description = "port 80"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.tf-vpc.cidr_block]
  }


  tags = {
    Name = "tf-sg"
  }
}
# internet gateway
resource "aws_internet_gateway" "tf-ig" {
  vpc_id = aws_vpc.tf-vpc.id

  tags = {
    Name = "tf-ig"
  }
}
#route table
resource "aws_route_table" "tf-r" {
  vpc_id = aws_vpc.tf-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.tf-ig.id
  }
}
#route table association
resource "aws_route_table_association" "route-table" {
  subnet_id      = aws_subnet.tf-subnet.id
  route_table_id = aws_route_table.tf-r.id
  }

# key pair
resource "aws_key_pair" "tf-key" {
  key_name   = "key-pair"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDqANc/6FZYL222gRmeWbiWJB679YBhRnu4Qne6tKAaEaHge37MIe4V4uq+9TkLdegvA8RfQdazsYBcJRze8wr3fWMUZSp12K7X/vCfr1bUB6vbcqFxsWAiWOGye5Osc0Dx3DVXvCf45fSdtoaHhIwKzsaeUCq/hLlIhk87LInfBQ2Eq5HsJ6sqNKhWu6kZFcOz6jMlkIjiXCNZvmA0G3liiBqz7VuYcLpx19L2LDPrLPISd9/MVPTl16F3t2rub9CzgaBOolngAW9r3NUO0Vf6UhaAvM5yFTmj2NfY/tPqLayIPrR6SFvjwbT82AZKtRbzbX9Z2u8+fp9G0y0b/sIYHJyZK6+r1zd3y5WCuO1J5nUeLHlBlUAGZXTw0bfciMG6kMejsqg4m3krLu+//oMo3+LXOzNtun6O/EN19S6uRam7HxXia5psToXi3rxoiCI+gnPVqUqIsvix4oJH11rRWagBV1jSFcVlY/2VgHrx82Ix84oUrtSDnCaPC9lMsn8= sford1@scratch-2022"
}
# make three instances

resource "aws_instance" "dev" {
  ami                         = "ami-04505e74c0741db8d"
  instance_type               = "t2.micro"
  security_groups             = [aws_security_group.tf-sg.id]
  associate_public_ip_address = true
  key_name                    = aws_key_pair.tf-key.key_name
  subnet_id                   = aws_subnet.tf-subnet.id
  user_data                   = <<-EOF
         #!/bin/bash
         wget http://cit.dixie.edu/it/3110/joe-notes-2021/terraform/install.sh -O /tmp/install.sh
         chmod +x /tmp/install.sh
         source /tmp/install.sh
         EOF
  tags = {
    Name = "dev"
  }
}
resource "aws_instance" "test" {
  ami                         = "ami-04505e74c0741db8d"
  instance_type               = "t2.micro"
  security_groups             = [aws_security_group.tf-sg.id]
  associate_public_ip_address = true
  key_name                    = aws_key_pair.tf-key.key_name
  subnet_id                   = aws_subnet.tf-subnet.id
  user_data                   = <<-EOF
         #!/bin/bash
         wget http://cit.dixie.edu/it/3110/joe-notes-2021/terraform/install.sh -O /tmp/install.sh
         chmod +x /tmp/install.sh
         source /tmp/install.sh
         EOF
  tags = {
    Name = "test"
  }
}
resource "aws_instance" "prod" {
  ami                         = "ami-04505e74c0741db8d"
  instance_type               = "t2.micro"
  security_groups             = [aws_security_group.tf-sg.id]
  associate_public_ip_address = true
  key_name                    = aws_key_pair.tf-key.key_name
  subnet_id                   = aws_subnet.tf-subnet.id
  user_data                   = <<-EOF
         #!/bin/bash
         wget http://cit.dixie.edu/it/3110/joe-notes-2021/terraform/install.sh -O /tmp/install.sh
         chmod +x /tmp/install.sh
         source /tmp/install.sh
         EOF
  tags = {
    Name = "prod"
  }
}
output "public_IP_for_dev" {
  #description = "public ip for dev instance"
  value       = aws_instance.dev.public_ip
}
output "public_IP_for_test" {
  #description = "public ip for test instance"
  value       = aws_instance.test.public_ip
}
output "public_IP_for_prod" {
  #description = "public ip for prod instance"
  value       = aws_instance.prod.public_ip
}
