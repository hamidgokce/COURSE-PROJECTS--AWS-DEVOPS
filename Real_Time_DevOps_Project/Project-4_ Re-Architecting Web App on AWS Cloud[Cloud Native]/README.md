# Project-4: Re-Architecting Web App on AWS Cloud[Cloud Native]

[*Project Source*](https://www.udemy.com/course/devopsprojects/?src=sac&kw=devops+projects)

 In my previous project(Project-3_Lift&Shift Application Workload to AWS), I used Lift&Shift strategy to move the application to AWS. Project 4 is about re-architecting the application using Cloud Native Services in AWS. Changes that I have done:
- 🔸 Used Elastic Beanstalk for deploying the application to Tomcat. It also created LoadBalancer, CloudWatch alarms, and ASG for the app servers
- 🔸 Replaced MySQL instance with RDS MySQL
- 🔸 Created ElastiCache service instead of Memcached instance
- 🔸 Used Amazon MQ service with RabbitMQ engine instead of RabbitMQ on an instance 
- 🔸 Created a CloudFront distribution for the application

## Pre-requisites:
  * AWS Account
  * Default VPC
  * Route53 Public Registered Name
  * Maven
  * JDK8

![Architecture](images/Project-4.png)

### Step-1: Create Keypair for Beanstalk EC2 Login

- We will create a key pair to be used with Elastic Beanstalk. Go to `EC2` console, on left menu select `KeyPair` -> `Create key pair`.
```sh
Name: 
```
- Remember where to download the private key, it will be used when logging in to EC2 via SSH.

### Step-2: Create Security Group for ElastiCache, RDS and ActiveMQ

- Create a Security Group with name `vprofile-backend-SG`. Once it is created we need to edit `Inbound` rules:
```sh
All Traffic from `vprofile-backend-SG`
```  
![Architecture](images/secgroup_for_backend.png)


### Step-3: Create RDS Database

#### Create Subnet Group:

- First we will create `Subnet Groups` with below properties:(If we have seperate vpc subnet group is useful)
```sh
Name: vprofile-rds-sub-grp
AZ: Select All
Subnet: Select All
```

#### Create Parameter Group

- We will create a parameter group to be used with our RDS instance. If we want to use default parameter group we don't need to create one. With parameter group, we are able make updates to default parameter for our RDS instance.
- A parameter group is a collection of engine configuration values that you set for your RDS database instance. It contains the mapping of what you want each of these over 400 unique parameters to be set to.

```sh
Parameter group family: mysql5.7
Type: DB Parameter Group
Group Name: vprofile-rds-para-grp
```

#### Create Database

- We will create RDS instance with below properties:
```sh
Method: Standard Create
Engine Options: MySQL
Engine version: 5.7.33
Templates: Free-Tier
DB Instance Identifier: vprofile-rds-mysql
Master username: admin
Password: Auto generate psw
Instance Type: db.t2.micro
Subnet grp: vprofile-rds-sub-grp
SecGrp:  vprofile-backend-SG
No public access
DB Authentication: Password authentication
Additional Configuration
Initial DB Name: accounts
Keep the rest default or you may add as your own preference
```

- After clicking `Create` button, you will see a popup. Click `View credential details` and note down auto-generated db password. We will use it in our application config files.

### Step-3: Create ElastiCache


#### Create Parameter Group

- We will create a parameter group to be used with our ElastiCache instance. If we want to use default parameter group we don't need to create one. With parameter group, we are able make updates to default parameters for our ElasticCache instance.

```sh
Name: vprofile-memcached-para-grp
Description: vprofile-memcached-para-grp
Family: memcached1.4
```

#### Create Subnet Group:

- First we will create `Subnet Groups` with below properties:
```sh
Name: vprofile-memcached-sub-grp
AZ: Select All
Subnet: Select All
```

#### Create Memcached Cluster

- Go to `Get Started` -> `Create Clusters` -> `Memcached Clusters`
```sh
Name: vprofile-elasticache-svc
Engine version: 1.4.5
Parameter Grp: vprofile-memcached-para-grp
NodeType: cache.t2.micro
Number of Nodes: 1
SecGrp: vprofile-backend-SG
```

### Step-4: Create Amazon MQ

- We will create Amazon MQ service with below properties:
```sh
Engine type: RabbitMQ
Single-instance-broker
Broker name: vprofile-rmq
Instance type: mq.t3.micro
username: rabbit
psw: Blue7890bunny
broker engine version: default 
Additional Settings:
private Access
VPC: use default
SEcGrp: vprofile-backend-SG
```

- Do not forget to note down your username/pwd. You won't be able to see your Password again from console.

### Step-5: DB Initialization

- Go to RDS instance copy endpoint.
```sh
vprofile-rds-mysql.cyicet2iv8su.us-east-1.rds.amazonaws.com
```

- Create an EC2 instance to initialize the DB, this instance will be terminated after initialization.
```sh
Name: mysql-client
OS: ubuntu 18.04
t2.micro
SecGrp: Allow SSH on port 22
Keypair: vprofile-prod-key
Userdata:

#! /bin/bash
apt update -y
apt upgrade -y
apt install mysql-client -y
```

- SSH into `mysl-client` instance. We can check mysql version
```sh
curl http://169.254.169.254/latest/user-data
# The 169.254.169.254 IP address is a “magic” IP in the cloud world, in AWS it used to retrieve user data and instance metadata specific to a instance. It can only be accessed locally from instances and available without encryption and authentication.
mysql -V
```
![Architecture](images/mysql.png)


- Before we login to database, we need to update `vprofile-backend-SG` Inbound rule to allow connection on port 3306 for `mysql-client-SG`
After updating rule, try to connect with below command:
```sh
mysql -h vprofile-rds-mysql.cyicet2iv8su.us-east-1.rds.amazonaws.com -u admin -pGdkEoOolnmSh911no5VS
mysql> show databases;
```
![Architecture](images/secgroup_fixing.png)

- Next we will clone our source code here to use script to initialize our database. After these commands we should be able to see 2 tables `role`, `user`, and `user_role`.

```sh
git clone https://github.com/devopshydclub/vprofile-project.git 
  (git clone https://github.com/hamidgokce/COURSE-PROJECTS--AWS-DEVOPS.git)
  (cd COURSE-PROJECTS--AWS-DEVOPS/Real_Time_DevOps_Project/Project-4_\ Re-Architecting\ Web\ App\ on\ AWS\ Cloud\[Cloud\ Native\]/src/main/resources/)
cd vprofile-project
git checkout aws-Refactor
cd src/main/resources
mysql -h vprofile-rds-mysql.cyicet2iv8su.us-east-1.rds.amazonaws.com -u admin -pGdkEoOolnmSh911no5VS accounts < db_backup.sql
mysql -h vprofile-rds-mysql.cyicet2iv8su.us-east-1.rds.amazonaws.com -u admin -p8C0oRoIMSUwrJvjbVpVR accounts
show tables;
```

### Step-5: Create Elastic Beanstalk Environment

- Our backend services are ready now. We will copy their endpoints from AWS console. These information will be used in our `application.properties` file
```sh
RDS:
vprofile-rds-mysql.cyicet2iv8su.us-east-1.rds.amazonaws.com:3306

Rabbitmq
amqps://b-9fb5569a-ccd8-4c5a-b3b2-7be27757c2aa.mq.us-east-1.amazonaws.com:5671

ElastiCache:
vprofile-elasticache-svc.iz2nzo.cfg.use1.cache.amazonaws.com:11211
```

#### Create Application

- Application in Elastic Beanstalk means like a big container which can have multiple environments. Since out app is Running on Tomcat we will choose `Tomcat` as platform.
```sh
Name: vprofile-java-app
Platform: Tomcat
keep the rest default
Configure more options:
- Custom configuration
****Instances****
EC2 SecGrp: vprofile-backend-SG
****Capacity****
LoadBalanced
Min:2
Max:4
InstanceType: t2.micro
****Rolling updates and deployments****
Deployment policy: Rolling
Percentage :50 %
****Security****
EC2 key pair: vprofile-bean-key
```
![architecture](images/beanstalk.png)
![architecture](images/beanstalk2.png)
![architecture](images/ec2_instances_comefrom_elasticbeanstalk.png)


### Step-5: Update Backend SecGrp & ELB

- Our application instances created by BeanStalk will communicate with Backend services. We need update `vprofile-backend-SG` to allow connection from our appSecGrp created by Beanstalk on port `3306`, `11211` and `5671` 
```sh
Custom TCP 3306 from Beanstalk SecGrp(you can find id from EC2 insatnces)
Custom TCP 11211 from Beanstalk SecGrp
Custom TCP 5671 from Beanstalk SecGrp
```
![architecture](images/step5.png)

- In Elastic Beanstalk console, under our app environment, we need to clink Configuration and do below changes and apply:
```sh
Add Listener HTTPS port 443 with SSL cert
Processes: Health check path : /login
```

### Step-6: Build and Deploy Artifact

- Go to directory that we cloned project, we need to checkout aws-refactor branch. Update below fields in `application.properties` file with correct endpoints and username/pwd.
```sh
vim src/main/resources/application.properties
*****Updates*****
jdbc.url
jdbc.password
memcached.active.host
rabbitmq.address
rabbitmq.username
rabbitmq.password
```
![architecture](images/app_properties.png)

- Go to root directory of project to the same level with `pom.xml` file. Run below command to build the artifact.
```sh
mvn install
``` 

#### Upload Artifact to Elastic Beanstalk

- Go to Application versions and Upload the artifact from your local. It will autmatically upload the artifact to the S3 bucket created by Elasticbeanstalk.

- Now we will select our uploaded application and click Deploy.

![architecture](images/maven.png)

- Let's check if our application deployed successfully.

![architecture](images/beanstalk_uploaded.png)
![architecture](images/beanstalkendpoint.png)
![architecture](images/result.png)



### Step-7: Create DNS Record in Route53 for Application

- We will create an A record which aliasing Elastic Beanstalk endpoint.

- Now we can reach our application securely with DNS name we have given.


### Step-8: Create Cloudfront Distribution for CDN

- Cloudfront is Content Delivery Nettwork service of AWS. It uses Edge Locations around the world to deliver contents globally with best performance. We will to `CloudFront` and create a distribution.
```sh
Origin Domain: DNS record name we created for our app in previous step
Viewer protocol: Redirect HTTP to HTTPS
Alternate domain name: DNS record name we created for our app in previous step
SSL Certificate: 
Security policy: TLSv1
``` 
- Now we can check our application from browser.


### Step-9: Clean-up

- We will delete all resources that we have created throughout the project.