
provider "aws" {
  profile = "<bootstrap_profile_name>"
  region = "us-east-1" 
}

variable "uid" { default = "<account_uid>" }
