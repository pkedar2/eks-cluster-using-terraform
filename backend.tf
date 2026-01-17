terraform {
  backend "s3" {
    bucket         = "s3-for-state-file"
    key            = "eks/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }
}

