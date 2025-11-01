terraform {
  backend "s3" {
    # Update these values for your environment
    bucket  = "YOUR-TERRAFORM-STATE-BUCKET"
    key     = "production/iam/terraform.tfstate"
    region  = "eu-west-2"
    encrypt = true
  }
}
