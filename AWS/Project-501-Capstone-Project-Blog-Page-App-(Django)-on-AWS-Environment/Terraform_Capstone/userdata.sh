#! /bin/bash
apt-get update -y
apt-get install git -y
apt-get install python3 -y
cd /home/ubuntu/
TOKEN="XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
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