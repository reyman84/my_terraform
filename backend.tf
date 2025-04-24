terraform {
  backend "s3" {
    bucket = "job-hunt-2025"
    key    = "Terraform_VPC/backend-report"
    region = "us-east-1"
    #dynamodb_table = "terraform-locks"
  }
}