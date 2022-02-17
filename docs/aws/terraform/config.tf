terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.30.0"
    }
  }
}

provider "aws" {
  profile = "<bootstrap_profile_name>"
  region = "us-east-1" 
}

variable "uid" { default = "<account_uid>" }
