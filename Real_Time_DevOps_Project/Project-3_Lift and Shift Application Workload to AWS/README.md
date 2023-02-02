# Project-3:Lift&Shift Application Workflow to AWS

[*Project Source*](https://www.udemy.com/course/devopsprojects/?src=sac&kw=devops+projects)

- What is lift and shift cloud strategy?
    -   What is lift-and-shift migration? In the lift-and-shift approach to cloud migration, applications, systems, workloads, and data are moved from on-premises to the cloud with little or no changes. Resources hosted in the data center are copied and "lifted" from the on-premises infrastructure.

📌 In Project-3, with the Lift&Shift strategy, I have moved the application to AWS. Here is the flow of execution:
- Created Security Groups for ELB, Application, and Backend servers.
- Launched instances with user-data scripts.
- Created a Private Hosted Zone in Route53 and records to map IP addresses of backend services to DNS names.
- Built application artifacts with Maven
- Created S3 bucket and copied artifacts to S3 with AWS CLI commands.
- Setup ELB with HTTPS using SSL certificate from ACM.
- Created Route53 record for the application by aliasing ELB endpoint.
- Created an AMI from the application server, a Launch Template, and ASG for Tomcat application instances.


## Prerequisites:
 * AWS Account
 * Registered DNS Name
 * Maven
 * JDK8
 * AWS CLI

##### Architecture on DataCenter:
![Architecture-on-DC](images/Before-AWS.png)

##### Architecture on AWS:
![Architecture-on-AWS](images/Project-3.png)



### Step-1: Create Security Groups for Services

- We will create `proje3-ELB-SG` first. We will configure `Inbound` rules to Allow both `HTTP` and `HTTPS` on port `80` and `443` respectively  from Anywhere `IPv4` and `IPv6`.
![](images/ELB-SecGrp.png)

- Next we will create `proje3-app-SG`. We will open port `8080` to accept connections from `vprofile-ELb-SG`.
![](images/App-SecGrp.png)

- Finally, we will create `proje3-backend-SG`. WE need to open port `3306` for `MySQL`, `11211` for `Memcached` and `5672` for `RabbitMQ` server. We can check whcih ports needed fro aplication services to communicate each other from `application.properties` file under `src/main/resources` directory.We also need to open commucation `AllTraffic` from own SecGrp for backend services to communicate with each other.
![](images/Backend-SecGrp.png)

### Step-2: Create KeyPair to Connect EC2 instances

- We will create a Keypair to connect our instances via SSH.
![](images/KeyPair.png)


### Step-3: Provision Backend EC2 instances with UserData script

##### DB Instance:

- Create DB instance with below details.We will also add Inbound rule to `proje3-backend-SG` for `SSH` on port `22`  from `MyIP` to be able to connect our db instance via SSH.
```sh
Name: proje3-db01
Project: vprofile
AMI: Centos 7
InstanceType: t2.micro
SecGrp: proje3_backend_sg
UserData: mysql.sh
```
- Once our instance is ready, we can SSH(We have to open port 22 for ssh) into the server and check if userdata script is executed.We can also check status of mariadb.
```sh
ssh -i proje3_key.pem centos@<public_ip_of_instance>
sudo su -
curl http://169.254.169.254/latest/user-data
# The 169.254.169.254 IP address is a “magic” IP in the cloud world, in AWS it used to retrieve user data and instance metadata specific to a instance. It can only be accessed locally from instances and available without encryption and authentication.
systemctl status mariadb
# If mariadb does not appear to be running, we can see the ongoing processes with the ps -ef command.
```
![](images/mariadb-running.png)

##### Memcached Instance:

- Create Memcached instance with below details.
```sh
Name: proje3-mc01
Project: vprofile
AMI: Centos 7
InstanceType: t2.micro
SecGrp: proje3_backend_sg
UserData: memcache.sh
```
- Once our instance is ready, we can SSH into the server and check if userdata script is executed.We can also check status of memcache service and if it is listening on port 11211.
```sh
ssh -i proje3_key.pem centos@<public_ip_of_instance>
sudo su -
curl http://169.254.169.254/latest/user-data
systemctl status memcached.service
ss -tunpl | grep 11211
```
![](images/memcached-running.png)

##### RabbitMQ Instance:

- Create RabbitMQ instance with below details.
```sh
Name: proje3-rmq01
Project: vprofile
AMI: Centos 7
InstanceType: t2.micro
SecGrp: proje3_backend_sg
UserData: rabbitmq.sh
```
- Once our instance is ready, we can SSH into the server and check if userdata script is executed.We can also check status of rabbitmq service.
```sh
ssh -i proje3_key.pem centos@<public_ip_of_instance>
sudo su -
curl http://169.254.169.254/latest/user-data
systemctl status rabbitmq-server
```
![](images/rabbitmq-running.png)

_Note: It may take some time to run userdata script after you connect to server. You can check the process `ps -ef` to see if the process start for service. If not wait sometime and check with `systemctl status <service_name>` command again._

### Step-3: Create Private Hosted Zone in Route53 

- Our backend stack is running. Next we will update Private IP of our backend services in Route53 Private DNS Zone. Lets note down Private IP addresses.
```sh
rmq01 172.31.57.219
db01 172.31.84.70
mc01 172.31.49.104
```
- Create `proje3` Private Hosted zone in Route53. We will pick `Default VPC` in `N.Virginia` region.

![](images/route53-records.png)

- Now we will create records for our backend services. The purpose of this activity is we will use these record names in our `application.properties` file. Even if IP address of the services, our application won't need to change the config file.  
```sh
Simple Routing -> Define Simple Record
Value/Route traffic to: IP address or another value
```
![](images/backend-records.png)
![](images/backend-records-2.png)


### Step-4: Provision Application EC2 instances with UserData script

- Create Tomcat instance with below details.We will also add Inbound rule to `proje3-app-SG` for `SSH` on port `22`  from `MyIP` to be able to connect our db instance via SSH.
```sh
Name: proje3-app01
Project: vprofile
AMI: Ubuntu 18.04
InstanceType: t2.micro
SecGrp: proje3_app_sg
UserData: tomcat_ubuntu.sh
```


### Step-5: Create Artifact Locally with MAVEN

![](images/powershell.png)
- Clone the repository.
```sh
git clone https://github.com/hamidgokce/COURSE-PROJECTS--AWS-DEVOPS.git
```

- Before we create our artifact, we need to do changes to our `application.properties` file under `/src/main/resources` directory for below lines.
![](images/change.png)
```sh
jdbc.url=jdbc:mysql://db01.vprofile.in:3306/accounts?useUnicode=true&

memcached.active.host=mc01.vprofile.in

rabbitmq.address=rmq01.vprofile.in
```
- We will go to `vprofile-project` root directory to the same level pom.xml exists. Then we will execute below command to create our artifact `vprofile-v2.war`:

```sh
mvn install
```
![](images/mvn-build-successArtifact-created.png)

### Step-6: Create S3 bucket using AWS CLI, copy artifact

- We will upload our artifact to s3 bucket from AWS CLI and our Tomcat server will get the same artifact from s3 bucket.

- We will create an IAM user for authentication to be used from AWS CLI.

![](images/aws_cli_installation.png)

```sh
name: proje3-s3-admin
Access key - Programmatic access
Policy: s3FullAccess
```
![](images/iam-user.png)

- Next we will configure our `aws cli` to use iam user credentials.
```sh
aws configure
AccessKeyID: 
SecretAccessKey:
region: us-east-1
format: json
```
- Create bucket. Note: S3 buckets are global so the naming must be UNIQUE!
```sh
aws s3 mb s3://proje3-artifact-storage-rd
```
- Go to target directory and copy the artifact to bucket with below command. Then verify by listing objects in the bucket.
```sh
aws s3 cp vprofile-v2.war s3://proje3-artifact-storage-rd
aws s3 ls proje3-artifact-storage-rd
```
- We can verify the same from AWS Console.

![](images/s3-created.png)

### Step-7: Download Artifact to Tomcat server from S3

- In order to download our artifact onto Tomcat server, we need to create IAM role for Tomcat. Once role is created we will attach it to our `app01` server.
```sh
Type: EC2
Name: proje3-artifact-storage-role
Policy: s3FullAccess
```
- Before we login to our server, we need to add SSH access on port 22 to our `proje3_app_sg`.

- Then connect to `app011` Ubuntu server.
```sh
ssh -i "proje3_key.pem" ubuntu@<public_ip_of_server>
sudo su -
systemctl status tomcat8
```

- We will delete `ROOT` (where default tomcat app files stored) directory under `/var/lib/tomcat8/webapps/`. Before deleting it we need to stop Tomcat server. 
```sh
cd /var/lib/tomcat8/webapps/
systemctl stop tomcat8
rm -rf ROOT
```
- Next we will download our artifact from s3 using aws cli commands. First we need to install `aws cli`. We will initially download our artifact to `/tmp` directory, then we will copy it under `/var/lib/tomcat8/webapps/` directory as `ROOT.war`. Since this is the default app directory, Tomcat will extract the compressed file.
```sh
apt install awscli -y
aws s3 ls s3://proje3-artifact-storage-rd
aws s3 cp s3://proje3-artifact-storage-rd/vprofile-v2.war /tmp/vprofile-v2.war
cd /tmp
cp vprofile-v2.war /var/lib/tomcat8/webapps/ROOT.war
systemctl start tomcat8
```

- We can also verify `application.properties` file has the latest changes.
```sh
cat /var/lib/tomcat8/webapps/ROOT/WEB-INF/classes/application.properties
```

- We can validate network connectivity from server using `telnet`.
```sh
apt install telnet
telnet db01.proje3.abdulhamidgokce.com 3306
```

### Step-8: Setup LoadBalancer

- Before creating LoadBalancer , first we need to create Target Group.
```sh
Intances
Target Grp Name: proje3-elb-TG
protocol-port: HTTP:8080
healtcheck path : /login
Advanced health check settings
Override: 8080
Healthy threshold: 3
available instance: app01 (Include as pending below)
```

- Now we will create our Load Balancer.
```sh
proje3-prod-elb
Internet Facing
Select all AZs
SecGrp: proje3_ELB_SG
Listeners: HTTP, HTTPS
Select the certificate for HTTPS
```

### Step-9: Create Route53 record for ELB endpoint

- We will create an A record with alias to ALB so that we can use our domain name to reach our application.

![](images/record-for-elb.png)

- Lets check our application using our DNS. We can securely connect to our application!

![](images/vprofileapp-https.png)  

### Step-10: Configure AutoScaling Group for Application Instances

- We will create an AMI from our App Instance.

![](images/vprofile-ami.png)

- Next we will create a Launch template using the AMI created in above step for our ASG.
```sh
Name: proje3-app-LC
AMI: proje3-app-image
InstanceType: t2.micro
IAM Profile: proje3-artifact-storage-role
SecGrp: proje3_app-sg
KeyPair: proje3_key
```

- Our Launch template is ready, now we can create our ASG.
```sh
Name: proje3-app-ASG
ELB healthcheck
Add ELB
Min:1
Desired:2
Max:4
Target Tracking-CPU Utilization 50
```
- If we terminate any instances we will see ASG will create a new one using LT that we created.

![](images/asg-provisioning-instance.png)

### Step-11: Clean-up

- Delete all resources we created to avoid any charges from AWS.