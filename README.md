# CapstoneProject_Group4_Infra

## Overal Architecture 

![Overal Architecture](/images/G4_CapstoneProject_V5.jpg "This is Overal Architecture.")

## REPO SECRETS
* AWS_ACCESS_KEY_ID_NTU = **your-access-key-id**
* AWS_SECRET_ACCESS_KEY_NTU = **your-secret-access-key**
* SNYK_TOKEN = **your-snyk-token**
* AWS_REGION = **us-east-1**
* DEV_ALLOWED_ORIGIN = *
* PROD_ALLOWED_ORIGIN = *

## REPO VARIABLES
* S3_BUCKET_FOR_TF_STATE_FILE = **ce11-capstone-group4**
* AZS = **["us-east-1a","us-east-1b"]**

## UI
# Sign up
![Sign up 01](/images/UI/Signup1.JPG "Sign up 01")

![Sign up 02](/images/UI/Signup2.JPG "Sign up 02")

![Sign up 03](/images/UI/Signup3.JPG "Sign up 03")

![Sign up 04](/images/UI/Signup4.JPG "Sign up 04")

# Add Card
![Add Card 01](/images/UI/AddCard01.JPG "Add Card 01")

![Add Card 02](/images/UI/AddCard02.JPG "Add Card 02")

![Add Card 03](/images/UI/AddCard03.JPG "Add Card 03")

![Add Card 04](/images/UI/AddCard04-Profile.JPG "Add Card 04")

# Get Transactions
![Get Transactions](/images/UI/GetTransactions.JPG "Get Transactions")

## INSTRUCTIONS
* **Kindly read the output of CD and add the above REPO SECRETS as well as REPO VARIABLES**

## As of 17th December 2025, the following components have been DONE
* S3 bucket for website
* Cloudfront Distribution linked to S3 as Origin
* Cognito for Authorization
* MySQL RDS
* VPC
* Secret Manager
* Add Card API ---> Add Card SQS ---> Add Card Lambda ---> MySQL RDS
* EC2 Jump Host for Setting up and Manage RDS via Terraform
* Transaction History API ---> Transaction History Lambda ---> MySQL RDS

## TO-DO
* Topup Card API ---> Topup Card SQS ---> Top up Card Lambda ---> MySQL RDS
* Deduct Card API ---> Deduct Card SQS ---> Deduct Card Lambda ---> MySQL RDS

## TABLES SCHEMA
![Tables Schema](/images/Tables.JPG "Table Schema.")

## SOME INSTRUCTION
* After running the CD on your own branch in your own repo, kindly check AWS Secret Manager for mySql username and password to login and other information such as Database Name.
* Create one t3-micro EC2 in PUBLIC SUBNET to connecto the mySql RDS, remember to install necessary package to connect to mySql RDS, this needs to do manually for now, the task is to provision this jump host via Terraform.
* Run the Create SQL Statement as above to create simple CARDS table.
* Use AWS Console to look for Add Card Invoke URL in AWS Gateway API, the Invoke URL should be in Stage Section
