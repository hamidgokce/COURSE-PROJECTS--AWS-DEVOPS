
data "aws_ami" "ubuntu" {
    most_recent = true

    filter {
        name   = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
    }

    filter {
        name   = "virtualization-type"
        values = ["hvm"]
    }

    owners = ["099720109477"] # Canonical
}


# Before using this userdate, please make sure the correct words used with sed command is located into the settings.py and .env files
data "template_file" "userdata" {
  template = <<EOF
#! /bin/bash
apt-get update -y
apt-get install git -y
apt-get install python3 -y
cd /home/ubuntu/
TOKEN="XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
git clone https://$TOKEN@github.com/serdarcw/serdar-aws-capstone.git
cd /home/ubuntu/serdar-aws-capstone
apt-get update -y
apt install python3-pip -y
apt-get install python3.7-dev libmysqlclient-dev -y
pip3 install -r requirements.txt
cd /home/ubuntu/serdar-aws-capstone/src/cblog
sed -i "s/database name in RDS is written here/${var.dbname}/g" settings.py
sed -i "s/database master username in RDS is written here/${var.dbusername}/g" settings.py
sed -i "s/database endpoint is written here/${aws_db_instance.my_db_instance.address}/g" settings.py
sed -i "s/database port is written here/3306/g" settings.py
sed -i "s/please enter your s3 bucket name/${local.bucket_name}/g" settings.py
sed -i "s/please enter your s3 region/${local.region}/g" settings.py
cd /home/ubuntu/serdar-aws-capstone/src
sed -i "s/your DB password without any quotes/${var.dbpassword}/g" .env
python3 manage.py collectstatic --noinput
# python3 manage.py makemigrations
# python3 manage.py migrate
python3 manage.py runserver 0.0.0.0:80
  EOF
}
resource "aws_launch_template" "aws_capstone_launch_template" {
  name = "aws_capstone_launch_template"
  image_id = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  key_name = var.key_pair
  iam_instance_profile {
    arn = aws_iam_instance_profile.test_profile.arn
  }
  vpc_security_group_ids = [aws_security_group.aws_capstone_EC2_Sec_Group.id]
  tag_specifications {
    resource_type = "instance"
    tags = local.tags
  }
  user_data = base64encode(data.template_file.userdata.rendered)
}


# To install web-app, we need to create initial instance with different user data. it will create database tables and s3 static files. than autoscaling group creates new other instances in which don't have migrate commands. We'll add this intial instance to the target group. 

data "template_file" "userdata_first_ec2" {
  template = <<EOF
#! /bin/bash
apt-get update -y
apt-get install git -y
apt-get install python3 -y
cd /home/ubuntu/
TOKEN="XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
git clone https://$TOKEN@github.com/serdarcw/serdar-aws-capstone.git
cd /home/ubuntu/serdar-aws-capstone
apt-get update -y
apt install python3-pip -y
apt-get install python3.7-dev libmysqlclient-dev -y
pip3 install -r requirements.txt
cd /home/ubuntu/serdar-aws-capstone/src/cblog
sed -i "s/database name in RDS is written here/${var.dbname}/g" settings.py
sed -i "s/database master username in RDS is written here/${var.dbusername}/g" settings.py
sed -i "s/database endpoint is written here/${aws_db_instance.my_db_instance.address}/g" settings.py
sed -i "s/database port is written here/3306/g" settings.py
sed -i "s/please enter your s3 bucket name/${local.bucket_name}/g" settings.py
sed -i "s/please enter your s3 region/${local.region}/g" settings.py
cd /home/ubuntu/serdar-aws-capstone/src
sed -i "s/your DB password without any quotes/${var.dbpassword}/g" .env
python3 manage.py collectstatic --noinput
python3 manage.py makemigrations
python3 manage.py migrate
python3 manage.py runserver 0.0.0.0:80
  EOF
}

resource "aws_instance" "initial_ec2" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  key_name = var.key_pair
  vpc_security_group_ids = [aws_security_group.aws_capstone_EC2_Sec_Group.id]
  subnet_id = aws_subnet.aws_capstone_vpc_private_subnet_A.id
  user_data = base64encode(data.template_file.userdata_first_ec2.rendered)
  tags = local.tags
}

# Target group attachment. we added initial ec2 to target group and we are able to attach target grup while creating autoscaling group. however, autoscaling group didn't see this initial ec2, even though we added initial ec2 to target group. to add this machine, we run these blogs on below. they will attach initial ec2 to autoscaling group usin CLI commands. finally, we need to be sure export aws profile correctly. this commands will be executed on our own shel and sometimes AWS_PROFILE might be set as different account.

resource "null_resource" "attach_initial_ec2_to_autoscaling_group" {
  depends_on = [aws_autoscaling_group.web-asg]
  provisioner "local-exec" {
    command = <<EOT
    export AWS_PROFILE=${local.aws_profile}
    aws autoscaling attach-instances --instance-ids ${aws_instance.initial_ec2.id} --region ${local.region} --auto-scaling-group-name ${aws_autoscaling_group.web-asg.name}
    EOT
  }
}