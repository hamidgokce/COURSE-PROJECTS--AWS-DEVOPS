resource "aws_db_subnet_group" "aws_capstone_vpc_db_subnet_group" {
  name       = "aws_capstone_vpc_db_subnet_group"
  subnet_ids = [aws_subnet.aws_capstone_vpc_private_subnet_A.id, aws_subnet.aws_capstone_vpc_private_subnet_B.id]
  description = "Subnets available for the RDS DB Instance"

  tags = {
    Name = "My DB subnet group"
  }
}

resource "aws_db_instance" "my_db_instance" {
  allocated_storage    = 10
  engine               = "mysql"
  engine_version       = "8.0.20"
  identifier           = "my-db-instance"
  instance_class       = var.dbtype
  name                 = var.dbname
  username             = var.dbusername
  password             = var.dbpassword
  port                 = 3306
  allow_major_version_upgrade = false
  auto_minor_version_upgrade = true
  skip_final_snapshot  = true
  max_allocated_storage = 20
  db_subnet_group_name  = aws_db_subnet_group.aws_capstone_vpc_db_subnet_group.id
  vpc_security_group_ids = [aws_security_group.aws_capstone_RDS_Sec_Group.id]
  maintenance_window = "Mon:00:00-Mon:03:00"
  backup_window      = "04:00-06:00"
}