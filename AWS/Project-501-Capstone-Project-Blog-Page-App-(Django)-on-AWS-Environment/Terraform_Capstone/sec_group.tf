resource "aws_security_group" "aws_capstone_ALB_Sec_Group" {
  name        = "aws_capstone_ALB_Sec_Group"
  description = "Allow SSH, HTTP inbound traffic"
  vpc_id      = aws_vpc.aws_capstone_vpc.id

  dynamic "ingress" {
    for_each = var.serdar-dynamic-ports
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name = "allow_https_http"
  }
}

resource "aws_security_group" "aws_capstone_EC2_Sec_Group" {
  name        = "aws_capstone_EC2_Sec_Group"
  description = "Allow SSH, HTTP inbound traffic"
  vpc_id      = aws_vpc.aws_capstone_vpc.id

  dynamic "ingress" {
    for_each = var.serdar-dynamic-ports
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      security_groups = [aws_security_group.aws_capstone_ALB_Sec_Group.id]
    }
  }
  ingress {
    description = "HTTP from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name = "allow_ssh_http_https"
  }
}

resource "aws_security_group" "aws_capstone_RDS_Sec_Group" {
  name        = "aws_capstone_RDS_Sec_Group"
  description = "Allow mysql port inbound traffic"
  vpc_id      = aws_vpc.aws_capstone_vpc.id

  ingress {
    description = "Mysql from Ec2 sec group"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    security_groups = [aws_security_group.aws_capstone_EC2_Sec_Group.id]

  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name = "aws_capstone_RDS_Sec_Group"
  }
}

resource "aws_security_group" "aws_capstone_bastion_host_sec_grp" {
  name        = "aws_capstone_bastion_host_sec_grp"
  description = "Allow SSH port from anywhere"
  vpc_id      = aws_vpc.aws_capstone_vpc.id

  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name = "aws_capstone_bastion_host_sec_grp"
  }
}