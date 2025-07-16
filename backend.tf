/*resource "aws_dynamodb_table" "terraform_lock" {
  name         = "Terraform_VPC"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  server_side_encryption {
    enabled = true
  }

  tags = {
    Name        = "Terraform Lock Table"
    Environment = "Dev"
  }
}*/

terraform {
  backend "s3" {
    bucket = "terraform.tfstate2025"
    key    = "backend-report"
    region = "us-east-1"
    #dynamodb_table = "Terraform_VPC"
    encrypt = true
  }
}