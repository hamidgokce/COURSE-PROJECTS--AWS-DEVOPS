terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
    github = {
      source  = "integrations/github"
      version = "~> 4.0"
    }
  }
}


# provider "github" {
#   token = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
# }

provider "aws" {
  region = "us-east-1"
  # secret_key = "xxxxxx"
  # access_key = "xxxxxx"
}

# resource "github_repository" "myrepo" {
#   name = "bookstoreapi"
#   auto_init = true
#   visibility = "private"
# }

# resource "github_branch_default" "main" {
#   branch = "main"
#   repository = github_repository.myrepo.name
# }

# variable "files" {
#   default = ["bookstore-api.py", "docker-compose.yml", "Dockerfile", "requirements.txt"]
# }

# resource "github_repository_file" "app-files" {
#   for_each = toset(var.files)
#   content = file(each.value)
#   file = each.value
#   repository = github_repository.myrepo.name
#   branch = "main"
#   commit_message = "app-files added to repo"
#   overwrite_on_create = true
# }

resource "aws_instance" "tf-docker-ec2" {
  ami = "ami-0022f774911c1d690"
  instance_type = "t2.micro"
  key_name = "EC2_key"
  security_groups = ["tf-docker-sec-gr-203"]
  tags = {
    Name = "Web Server of Bookstore"
  }
  user_data = <<-EOF
          #! /bin/bash
          yum update -y
          amazon-linux-extras install docker -y
          systemctl start docker
          systemctl enable docker
          usermod -a -G docker ec2-user
          curl -L "https://github.com/docker/compose/releases/download/1.26.2/docker-compose-$(uname -s)-$(uname -m)" \
          -o /usr/local/bin/docker-compose
          chmod +x /usr/local/bin/docker-compose
          mkdir -p /home/ec2-user/bookstore-api
          TOKEN="xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
          FOLDER="https://$TOKEN@raw.githubusercontent.com/hamidgokce/bookstoreapi/main/"
          curl -s --create-dirs -o "/home/ec2-user/bookstore-api/app.py" -L "$FOLDER"bookstore-api.py
          curl -s --create-dirs -o "/home/ec2-user/bookstore-api/requirements.txt" -L "$FOLDER"requirements.txt
          curl -s --create-dirs -o "/home/ec2-user/bookstore-api/Dockerfile" -L "$FOLDER"Dockerfile
          curl -s --create-dirs -o "/home/ec2-user/bookstore-api/docker-compose.yml" -L "$FOLDER"docker-compose.yml
          cd /home/ec2-user/bookstore-api
          docker build -t hamidgokce/bookstoreapi:latest .
          docker-compose up -d
          EOF
  # depends_on = [github_repository.myrepo, github_repository_file.app-files]

}


resource "aws_security_group" "tf-docker-sec-gr-203" {
  name = "tf-docker-sec-gr-203"
  tags = {
    Name = "tf-docker-sec-gr-203"
  }

  ingress {
    from_port = 22
    protocol = "tcp"
    to_port = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 80
    protocol = "tcp"
    to_port = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    protocol = "-1"
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

}

output "website" {
  value = "http://${aws_instance.tf-docker-ec2.public_dns}"

}
