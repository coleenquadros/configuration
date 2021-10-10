# Terraform init via terraform

These terraform files are used to set up the initial user and S3 backend for terraform for an AWS account which is not under terraform control.

The s3 backend is used to share state and is set up with a bucket policy allowing strict access as the state files have highly sensitive content including keys.

To get started point the config.tf file to a profile in ~/.aws/credentials that has access to create IAM users and S3 buckets. For the initial setup you also need to hard code the ARN of the creating user in bucket policy in terraform-setup.tf - terraform will refuse to lock you out of the bucket. 

Make sure you have terraform 0.13.5 from https://www.terraform.io/downloads.html and execute the following

    terraform init
    terraform plan
    terraform apply 
