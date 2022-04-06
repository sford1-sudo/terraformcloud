

  # beginning
 
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 2.70"
    }
  }
}

provider "aws" {
  profile = "default"
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
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  ingress {
    description = "port 80"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
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
  key_name   = "Key-pair"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDd4tuK+9+WyS+IQXzp0bx8iWS/NvxgoiOLE4n/W1jnIudGjTwzpqzWyA4rJmv2mDKqLGB58cIfQzssqArUUl2KL7mkhlET+RhaaWunvZMJ90NjcJNcbF/83Y+Yv685QkttRK/SbXSjchurLwnYISl3r8J3QtcqwgfRP+n8tg3+mQBitmfIHM1K/w51xXSZ1qiK9BMK1VxoCEYIJAa2fk/La/WUMu8nfo3J1a8d0cmwU9pGo+RCoBkoWRzqmG+QyxdCm4tx4+enX4it04IcO4nB32mTEI6H2kJH2Wby6CEWolv1bYzcwg2VEhy3XVWa8SxEczaxgQzgiHSVCFA0o7patkRBeYnqVbfeEJS7gc6sMfcUXhyQmsIEpOxahJIhg3ayApUhI2k9MGGvCvvfN7QsNMFSwpD1V1SUQcerc3/QSWFqhBCldOBGlJYbw6Yff5rjeoJIXgb3LHlCn4a7W1aBmU9IRaVQw0iAOPqWESXdKMSxLT5wjYZ987M1AnmFDwE= sford1@scratch-2022"
}
# make three instances

resource "aws_instance" "exam" {
  ami                         = "ami-04505e74c0741db8d"
  instance_type               = "t2.medium"
  security_groups             = [aws_security_group.tf-sg.id]
  associate_public_ip_address = true
  key_name                    = aws_key_pair.tf-key.id
  subnet_id                   = aws_subnet.tf-subnet.id
  user_data                   = <<-EOF
         #!/bin/bash
         wget http://cit.dixie.edu/it/3110/joe-notes-2021/terraform/install.sh -O /tmp/install.sh
         chmod +x /tmp/install.sh
         source /tmp/install.sh
         EOF
  tags = {
    Name = "exam"
  }
}

output "public_IP_for_exam" {
  #description = "public ip for dev instance"
  value       = aws_instance.exam.public_ip
}
output "name_for_VM" {
  value       = aws_instance.exam.Name
}
