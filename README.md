# dockerized_java

## Project Overview

1. Introduction  :
* Project Name: Dockerized Java Application on AWS
* Description: Deploy a Java web application on AWS using Terraform for infrastructure automation and Docker for containerization. Includes MySQL for the database and Redis for caching.
* Objective: Demonstrate scalable, high-availability deployment on AWS with Terraform and Docker.

2. Project Components
* AWS Cloud: Use AWS services like VPC, EC2, and RDS.
* Terraform: Automate infrastructure setup.
* Docker: Containerize the application.
* Docker Compose: Manage multi-container setup.
* Java and Maven: Build the application.
* MySQL: Primary database.
* Redis: Caching mechanism.

## Prerequisites

1. AWS Account

2. AWS IAM User
Create IAM User with Administrator Access
Generate Access Keys

3. AWS CLI
Install AWS CLI
Configure AWS CLI with Access Keys with IAM user credentials


(Process for configuration of the IAM user


For Windows:



Download the Installer:


Go to the AWS CLI version 2 download page.


Download the Windows 64-bit or 32-bit installer based on your system.


Run the Installer:

Double-click the downloaded .msi file and follow the on-screen instructions.


Verify Installation:

Open Command Prompt or PowerShell and run:
`
aws --version
`
This command should display the AWS CLI version installed.


Configure AWS CLI with IAM User Credentials


Open Command Prompt.


Run the AWS CLI configuration command:
`
aws configure
`


Enter your IAM user credentials when prompted:


*AWS Access Key ID: Enter your IAM user's access key ID.


*AWS Secret Access Key: Enter your IAM user's secret access key.


*Default region name: Enter the AWS region you want to use, such as us-east-1.


*Default output format: Enter the format you want the output in, such as json.)


4. Terraform


Install Terraform on your local machine

(Install Terraform
For Windows:


Extract the ZIP file: Unzip the downloaded file. It will contain a terraform.exe file.


Move to a directory in your PATH: Move the terraform.exe file to a directory included in your system’s PATH (e.g., C:\Program Files\Terraform\ or C:\Windows\System32).


Verify installation: Open Command Prompt and type terraform --version to ensure it's installed correctly.)


Verify Terraform Installation
`
terraform --version
`

5. Visual Studio Code
Install Visual Studio Code
Install Required Extensions(in the markeetplace):


Terraform Extension


Docker Extension


Git Extension

## Procedure

1. Clone the current repository on to your local machine which contain the requied terraform files for the project ot run.
2. Using visual studio code as your IDE, open the directory where the terraform project files are located.
3. In the main.tf file some changes are required to be made. They are mentioned below


*Security Groups Configuration:


Inbound Rules:


SSH (port 22) from any IP


HTTP (port 80) from any IP


Application port (8080) from any IP


MySQL (port 3306) from any IP


Redis (port 6379) from any IP


Outbound Rules: Allow all traffic.

*Launch Configuration:


Configuration:
AMI: ami-0604d81f2fd264c7b (Changes with region we are using)


Instance Type: t3.medium


Key Pair: keypair (Use the key available in that particular region)

*Auto Scaling Group

Purpose: Automatically adjust the number of EC2 instances based on load.


Configuration:


Subnets: Use subnets in different availability zones.


Min/Max Size: 1 to 3 instances.


Desired Capacity: 1 instance initially.


Scaling Policies: Adjusts the number of instances based on CPU utilization alarms.


*CloudWatch Alarms and Auto Scaling Policies

Purpose: Monitor the application’s performance and adjust resources as needed.


Configuration:


Alarms:


CPU High: Triggers scaling out when CPU utilization exceeds 70%.


CPU Low: Triggers scaling in when CPU utilization drops below 30%.


Scaling Policies:


Scale Out: Increase instance count by 1.


Scale In: Decrease instance count by 1.

4. After making the above changes, open the terminal in VS Code and change the path to the project directory.
5. Use the following commands to make the project run.


Initialize Terraform


First, navigate to your Terraform project directory and initialize Terraform:
`
terraform init
`


This command initializes the directory, downloading necessary provider plugins.


2. Validate the Configuration


To ensure your configuration files are syntactically valid:
`
terraform validate
`


3. Plan the Infrastructure


To create an execution plan and see what actions Terraform will take without actually applying them:
`
terraform plan
`


Apply the Configuration


To apply the changes required to reach the desired state of the configuration:
`
terraform apply
`


Destroy the Infrastructure


To destroy the infrastructure managed by Terraform:
`
terraform destroy
`

## Result

After following the above steps you will be having a loab balancer DNS which runs a java application.


Access the web application using the load balancer dns.
