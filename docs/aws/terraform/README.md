# Terraform init via terraform

These terraform files in this folder are used to set up the initial user and S3 backend for terraform for an AWS account which is not under terraform control.

The s3 backend is used to share state and is set up with a bucket policy allowing strict access as the state files have highly sensitive content including keys.

The bootstrapped terraform state will use a local backend for storage, meaning the output of the terraform operations will be saved locally to disk as `terraform.tfstate`. After you have captured the access key id and secret key id in the final step, you should delete this file.

## Prerequisites

1. aws-cli installed locally (details [here](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html))
2. terraform CLI version matching the version used by Qontract-Reconcile (check `TERRAFORM_VERSION` [here](https://github.com/app-sre/qontract-reconcile/blob/master/reconcile/cli.py)). You can download Terraform from https://www.terraform.io/downloads.html.
<details>
<summary>MacOS Example</summary>

  ```shell
    curl https://releases.hashicorp.com/terraform/0.13.7/terraform_0.13.7_darwin_amd64.zip -o terraform_0.13.7_darwin_amd64.zip
    # more binaries can be found here https://releases.hashicorp.com/terraform/
    unzip terraform_0.13.7_darwin_amd64.zip
    chmod +x terraform
    sudo mv terraform /usr/local/bin/
    # Test it
    terraform --version
  ```

</details>

3. decrypted AWS account access credentials + details

## Walkthrough

### Create a new aws cli profile for your new cluster

* Edit `~/.aws/config` and `~/.aws/credentials`, creating a new profile (i.e. `bootstrap-image-builder-stage`) using the decrypted access key id + secret access key. You'll need to reference this profile name in `config.tf` in the next step.

### Edit config.tf

* Edit line 11, changing `<bootstrap_profile_name>` to the new aws cli profile name you created, i.e. `bootstrap-image-builder-stage`
* Edit line 15, changing `<account_uid>` to the AWS account number, i.e. `123456789`

### Edit terraform-setup.tf

* Edit line 24, changing `<terraform_bucket_name>` to reference the new AWS account name, i.e. `terraform-image-builder-stage`
* Edit line 44, changing `<bootstraper_user_arn>` to a proper AWS IAM ARN, i.e. `arn:aws:iam::<AWS_ACCOUNT_NUMBER>:user/<ROOT_ACCOUNT_USERNAME>`

### Perform a terraform run

After saving the changes above, let's apply these changes to the live AWS account through terraform.

* `terraform init`
* `terraform plan`: the output of this step should show a new user, `terraform`, created in the account, as well as new S3 buckets
* `terraform apply`: this will reconcile the expected state (as shown in plan) with reality. The result of this operation is a new local state file, `terraform.tfstate`, which contains all details and secrets related to the creation of the new user and S3 bucket.

### Capture the terraform user's AWS keys for later use

Run `terraform show`, and capture the access key id and secret access key. You will need these to continue adding a new AWS account to app-interface. After you have captured the access key id and secret key id, you should delete `terraform.tfstate`.
