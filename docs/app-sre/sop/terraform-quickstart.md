getting started with terraform:
1. configure credentials (in this case - for the app-sre account): https://vault.devshift.net/ui/vault/secrets/app-sre/show/creds/terraform/app-sre/config
2. to configure a new profile - `aws configure` (aws cli)
3. make sure that for the app-sre account you create an aws profile called `terraform-aws02` (look in the vault secret under the `profile` key)
4. `terraform init`
5. `terraform plan` - applying everything in dry-run mode
6. if everything seems in order and as expected - `terraform apply`

PROFIT
