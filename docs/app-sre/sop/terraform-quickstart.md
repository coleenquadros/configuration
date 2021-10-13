getting started with terraform:
1. Look for the terraform version we're using in
   [`qontract-reconcile-base`](https://github.com/app-sre/container-images/blob/master/qontract-reconcile-base/Dockerfile)
   image, in the variable `TF_VERSION`.
2. configure credentials (in this case - for the app-sre account): https://vault.devshift.net/ui/vault/secrets/app-sre/show/creds/terraform/app-sre/config
3. to configure a new profile - `aws configure` (aws cli)
4. make sure that for the app-sre account you create an aws profile called `terraform-aws02` (look in the vault secret under the `profile` key)
5. `terraform init`
6. `terraform plan` - applying everything in dry-run mode
7. if everything seems in order and as expected - `terraform apply`

PROFIT
