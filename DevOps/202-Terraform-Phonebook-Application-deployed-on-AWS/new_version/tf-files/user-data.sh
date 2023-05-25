#! /bin/bash
yum update -y
yum install python3 -y
pip3 install flask
pip3 install flask_mysql
yum install git -y
# TOKEN=${user-data-git-token}
TOKEN="xxxxxxxxxxxxxxxxxxxxxxxx"
# USER=${user-data-git-name}
# cd /home/ec2-user && git clone https://$TOKEN@github.com/$USER/phonebook.git
cd /home/ec2-user && git clone https://$TOKEN@github.com/hamidgokce/COURSE-PROJECTS--AWS-DEVOPS.git
python3 /home/ec2-user/COURSE-PROJECTS--AWS-DEVOPS/DevOps/202-Terraform-Phonebook-Application-deployed-on-AWS/new_version/phonebook-app.py
