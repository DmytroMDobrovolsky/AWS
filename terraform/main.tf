terraform {
  required_version = ">=0.13.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "lab67-my-tf-state"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "lab67-my-tf-lockid"
  }
}

# Configure the AWS provider
provider "aws" {
  region = "us-east-1"
}

# Create a Security Group
resource "aws_security_group" "web_app" {
  name        = "web_app"
  description = "Security group for web application"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "web_app"
  }
}

# Create an EC2 instance
resource "aws_instance" "web_instance" {
  ami           = "ami-0866a3c8686eaeeba"
  instance_type = "t3.micro"
  vpc_security_group_ids = [aws_security_group.web_app.id] # Виправлено

  user_data = <<-EOF
  #!/bin/bash
  curl -fsSL https://get.docker.com -o get-docker.sh
  sudo sh get-docker.sh
  sudo groupadd docker
  sudo usermod -aG docker $USER
  newgrp docker
  docker pull dmytromdobrovolsky/aws:latest
  docker run -it dmytromdobrovolsky/aws:latest
  EOF

  tags = {
    Name = "webapp_instance"
  }
}

# Output the public IP of the instance
output "instance_public_ip" {
  value     = aws_instance.web_instance.public_ip
  sensitive = true
}
