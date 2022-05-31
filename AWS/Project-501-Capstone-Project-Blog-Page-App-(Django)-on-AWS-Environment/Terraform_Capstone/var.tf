variable "key_pair" {
  default = "serdar_client"
  #definition = "you keypair to connect EC2 on SSH port"
}

variable "vpc_cidr" {
  default = "90.90.0.0/16"
  #definition = "CIDR Block of Custom VPC"
}

variable "public_subnet_A_cidr" {
  default = "90.90.10.0/24"
  #definition = "CIDR Block of public subnet A"
}

variable "public_subnet_B_cidr" {
  default = "90.90.20.0/24"
  #definition = "CIDR Block of public subnet B"
}

variable "private_subnet_A_cidr" {
  default = "90.90.11.0/24"
  #definition = "CIDR Block of privare subnet A"
}

variable "private_subnet_B_cidr" {
  default = "90.90.21.0/24"
  #definition = "CIDR Block of privare subnet B"
}

variable "dbtype" {
  default = "db.t2.micro"
  #definition = "DB instance type of RDS instance"
}

variable "dbusername" {
  default = "admin"
  #definition = "RDS instance username"
}

variable "dbpassword" {
  default = "Clarusway1234"
  #definition = "RDS instance password of username"
}

variable "dbname" {
  default = "database1"
  #definition = "RDS instance initial database"
}

variable "instance_type" {
  default = "t2.micro"
  #definition = "EC2 instance type"
}

variable "serdar-dynamic-ports" {
  default = [80,443]
  #definition = "Dynamic ports of security groups"
}

variable "mydomainname" {
  default = "clarusway.us"
  #definition = "your Domain Name"
}

variable "sub_domain_name" {
  default = "www.clarusway.us"
  #definition = "your sub domain name to publish website"
}

variable "dynamo_write_capacity" {
  default = "3"
  #definition = "dynamo write capacity"
}

variable "dynamo_read_capacity" {
  default = "3"
  #definition = "dynamo read capacity"
}