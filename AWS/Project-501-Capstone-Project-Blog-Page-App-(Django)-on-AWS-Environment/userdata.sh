#!/bin/bash
apt-get update -y
apt-get install git -y
apt-get install python3 -y
cd /home/ubuntu/
# TOKEN="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"
# git clone https://$TOKEN@<YOUR GITHUB REPO URL>
git clone https://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@github.com/hamidgokce/COURSE-PROJECTS--AWS-DEVOPS.git
cd /home/ubuntu/COURSE-PROJECTS--AWS-DEVOPS
apt install python3-pip -y
apt-get install python3.7-dev libmysqlclient-dev -y
pip3 install -r requirements.txt
cd /home/ubuntu/COURSE-PROJECTS--AWS-DEVOPS/AWS/Project-501-Capstone-Project-Blog-Page-App-(Django)-on-AWS-Environment/src
python3 manage.py collectstatic --noinput
python3 manage.py makemigrations
python3 manage.py migrate
python3 manage.py runserver 0.0.0.0:80