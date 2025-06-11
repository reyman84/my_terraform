resource "aws_s3_bucket" "s3_bucket" {
  bucket = "myterraform-backend2025"  
}

resource "aws_dynamodb_table" "terraform_lock" {
  name = "Terraform_VPC"
  billing_mode = "PAY_PER_REQUEST"
  hash_key = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

terraform {
  backend "s3" {
    bucket = "myterraform-backend2025"
    key    = "Terraform_VPC/backend-report"
    region = "us-east-1"
    dynamodb_table = "Terraform_VPC"
  }
}