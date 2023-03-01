# Project-6: Continuous Integration on AWS Cloud

[*Project Source*](https://www.udemy.com/course/devopsprojects/?src=sac&kw=devops+projects)

### Pre-Requisites:

* AWS Account
* Sonar Cloud Account
* AWS CLI, Git installed on Local

![](images/Project-6.png)
![](images/Project-6-2.png)
![](images/Flow_of_execution.png)

### In Project-6, I created an automated Continuous Integration Pipeline using AWS Services. One advantage of this setup was eliminating operational overhead for maintaining servers like Jenkins, Nexus, and Sonar. With this project, I was able to:

* Create a CodeCommit repository and synchronize it with the local repository using SSH keys.
* Create a CodeArtifact repository for Maven dependencies to be stored/used during the build phase.
* Create a project in SonarCloud for Check Analysis.
* Created an S3 bucket to store build artifacts.
* Configure an SNS topic and subscribe to it for pipeline notifications.
* Configure CodePipeline with 4 stages: Source-Test-Build-Deploy, successfully trigger pipeline with any source code changes.

In my next project, I will set up a Continuous Delivery pipeline with Jenkins.


### Step-1: Setup AWS CodeCommit 

![](images/developer_tools.png)

From AWS Console, and pick `us-east-1` region and go to `CodeCommit` service. Create repository.
```sh
Name: vprofile-code-repo
```

Next we will create an IAM user with `CodeCommit` access from IAM console. We will create a policy for `CodeCommit` and allow full access only for `vprofile-code-repo`.

```sh
Name: vprofile-code-admin-repo-fullaccess
```

![](images/iam-codecommit-admin-user.png)

To be able connect our repo, we will follow steps given in CodeCommit.

![](images/repo-connection-steps.png)

First Create SSH key in local and add public key to IAM role Security credentials.

![](images/sshkey-generated-local.png)

We will also update configuration under `.ssh/config` and add our Host information. And change permissions with `chmod 600 config`
```sh
Host git-codecommit.us-east-1.amazonaws.com
    User <SSH_Key_ID_from IAM_user>
    IdentityFile ~/.ssh/vpro-codecommit_rsa
```

We can test our ssh connection to CodeCommit.
```sh
ssh git-codecommit.us-east-1.amazonaws.com
ssh -v git-codecommit.us-east-1.amazonaws.com # for troubleshooting purpose
```

![](images/codecommit-ssh-connection-successful.png)
![](images/clone-repo.png)

Next we clone the repository to a location that we want in our local. I will use the Github repository for `vprofile-project` in my local, and turn this repository to CodeCommit repository. When I am in Github repo directory, I will run below commands.
[Project code]( https://github.com/devopshydclub/vprofile-project.git)

```sh
git checkout master
git branch -a | grep -v HEAD | cut -d'/' -f3 | grep -v master > /c/Users/hamid/.ssh/vprofile-code-repo/branches # The location where the ssh command is executed
for i in `cat  /c/Users/hamid/.ssh/vprofile-code-repo/branches`; do echo $i; done
for i in `cat  /c/Users/hamid/.ssh/vprofile-code-repo/branches`; do git checkout $i; done
git fetch --tags
git remote rm origin
git remote add origin ssh://git-codecommit.us-east-1.amazonaws.com/v1/repos/vprofile-code-repo
cat .git/config
git push origin --all
git push --tags
```
- Our repo is ready on CodeCommit with all branches.

![](images/codecommit-repo-ready.png)

### Step-2: Setup AWS CodeArtifact

- We will create CodeArtifact repository for Maven. (Maven build job will download dependencies in here.)
```sh
Name: vprofile-maven-repo
Public upstraem Repo: maven-central-store
This AWS account
Domain name: visualpath
```

![](images/package_flow.png)
![](images/codeartifact-repositories.png)


- Again we will follow connection instructions given in CodeArtifact for  `maven-central-repo`.

![](images/artifact-connection-steps.png)

- We will need to create an IAM user for CodeArtifact and configure aws cli with its credentials. We will give Programmatic access to this user to be able to use aws cli and download credentials file.
```sh
aws configure # provide iam user credentials
```
![](images/iam-cart-admin-user.png)
![](images/codeartifact_token.png)


Then we run command get token as in the instructions.
```sh
export CODEARTIFACT_AUTH_TOKEN=`aws codeartifact get-authorization-token --domain visualpath --domain-owner 392530415763 --region us-east-1 --query authorizationToken --output text`
```

Update pom.xml and setting.xml file with correct urls as suggested in instruction and push these files to codeCommit.

![](images/settings_file.png)
![](images/changing_in_settingsxml.png)

```sh
git add .
git commit -m "message"
git push origin ci-aws
```
### Step-3: Setup SonarCloud 

We need to have an account, from account avatar -> `My Account` -> `Security`. Generate token name as `vprofile-sonartoken`. Note the token.

![](images/sonar-token.png)

Next we create a project, `+` -> `Analyze Project` -> `create project manually`. Below details will be used in our Build.
```sh
Organization: hamidgokce
Project key: hamidgokce-devops-projects
Public
```

Our Sonar Cloud is ready!
![](images/sonar-cloud-ready.png)

### Step-4: Store Sonar variables in System Manager Parameter Store 

We will create paramters for below variables.
```sh
CODEARTIFACT_TOKEN	 SecureString	
HOST      https://sonarcloud.io
ORGANIZATION           hamidgokce
PROJECT                hamidgokce-devops-projects
SONARTOKEN             SecureString
```
![](images/parameter_store.png)


### Step-5: AWS CodeBuild for SonarQube Code Analysis

From AWS Console, go to `CodeBuild` -> `Create Build Project`. This step is similar to Jenkins Job.
```sh
ProjectName: Vprofile-Build
Source: CodeCommit
Branch: ci-aws
Environment: Ubuntu
runtime: standard:5.0
New service role
Insert build commands from foler aws-files/sonar_buildspec.yml
Logs-> GroupName: vprofile-buildlogs
StreamName: sonarbuildjob
```

We need to update sonar_buildspec.yml file parameter store sections with the exact names we have given in SSM Parameter store.

We need to add a policy to the service role created for this Build project. Find name of role from Environment, go to IAM add policy as below:

![](images/ssm-parameter-access-policy.png)

It is time to Build our project.

![](images/sonarbuild-successful.png)

We can check from SonarCloud too.

![](images/sonarcloud-after-build.png)

I can add Quality Gate to this Build Project, we can create a Qulaity gate from SonarCloud and add to our project.

### Step-6: AWS CodeBuild for Build Artifact

From AWS Console, go to `CodeBuild` -> `Create Build Project`. This step is similar to Jenkins Job.
```sh
ProjectName: Vprofile-Build-Artifact
Source: CodeCommit
Branch: ci-aws
Environment: Ubuntu
runtime: standard:5.0
Use existing role from previous build
Insert build commands from foler aws-files/build_buildspec.yml
Logs-> GroupName: vprofile-buildlogs
StreamName: artifactbuildjob
```

Its time to build project.

![](images/build-artifact-success.png)

### Step-7: AWS CodePipeline and Notification with SNS

First we will create an SNS topic from SNS service and subscribe to topic with email.

![](images/sns-topic-created.png)

We need confirm our subscription from our email.

![](images/confirm-SNS-subscription.png)

Next we create an S3 bucket to store our deploy artifacts.

![](images/s3-for-storing-artifacts.png)

Lets create our CodePipeline.
```sh
Name: vprofile-CI-Pipeline
SourceProvider: Codecommit
branch: ci-aws
Change detection options: CloudWatch events
Build Provider: CodeBuild
ProjectName: vprofile-Build-Aetifact
BuildType: single build
Deploy provider: Amazon S3
Bucket name: vprofile98-build-artifact
object name: pipeline-artifact
```

We will add Test and Deploy stages to our pipeline.

Last step before running our pipeline is we need to setup Notifications, go to Settings in `CodePipeline` -> `Notifications`. 

Time to run our CodePipeline.

![](images/codepipeline-succesful.png)

### Step-8: Validate CodePipeline

We can make some changes in README file of source code, onc we push the changes CloudWatch will detect the changes and Notification event will trigger Pipeline.