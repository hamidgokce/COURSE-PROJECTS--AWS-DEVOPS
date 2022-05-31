# Adam's solution
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.58.0"
    }
  }
}
provider "aws" {
  region = "us-east-1"
}

resource "aws_security_group" "allow-ssh" {
  name        = "allow-ssh"
  description = "Port 22, 80 and 443 from all world"
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    description = "TLS from VPC"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    description = "worldwide"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "TCP"
    description = "worldwide"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "aws_ami" "amazon-linux-2" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}
resource "aws_instance" "apache-ec2" {
  ami                    = data.aws_ami.amazon-linux-2.id
  instance_type          = "t2.micro"
  count                  = 2
  key_name               = "EC2_key"
  vpc_security_group_ids = [aws_security_group.allow-ssh.id]
  user_data              = file("create_apache.sh")
  tags = {
    Name = "Terraform ${element(var.mytags, count.index)} Instance"
  }
  provisioner "local-exec" {
    command = "echo ${self.private_ip} >> private_ip.txt"
  }
  provisioner "local-exec" {
    command = "echo ${self.public_ip} >> public_ip.txt"
  }
}
variable "mytags" {
  type    = list(string)
  default = ["First", "Second"]
}
output "my-public-ip" {
  value = aws_instance.apache-ec2[*].public_ip
}