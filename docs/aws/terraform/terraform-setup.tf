
resource "aws_iam_user" "terraform" {
    name = "terraform"
}

resource "aws_iam_user_policy_attachment" "terraform-admin-access" {
    user       = aws_iam_user.terraform.name
    policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_access_key" "terraform-access-key" {
    user = aws_iam_user.terraform.name
}

output "terraform-aws_access_key_id" {
    value = aws_iam_access_key.terraform-access-key.id
}

output "terraform-aws_secret_access_key" {
    value = aws_iam_access_key.terraform-access-key.secret
}

resource "aws_s3_bucket" "terraform-bucket" {
  bucket = "<terraform_bucket_name>" # usually "terraform-<account_name>"
  acl = "private"

  versioning {
    enabled = true
  } 
}

resource "aws_s3_bucket_policy" "backend-policy" {
    bucket = aws_s3_bucket.terraform-bucket.id
    policy =<<POLICY
{
    "Version": "2012-10-17",
    "Id": "S3-backend-access",
    "Statement": [
        {
            "Effect": "Deny",
            "NotPrincipal": { 
                "AWS": [
                    "${aws_iam_user.terraform.arn}",
                    "<bootstraper_user_arn>"
                ] 
            },
            "Action": "s3:*",
            "Resource": "${aws_s3_bucket.terraform-bucket.arn}"
        }
    ]
}
POLICY
}
