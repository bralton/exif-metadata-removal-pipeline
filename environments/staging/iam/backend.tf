terraform {
  backend "s3" {
    # Update these values for your environment
    bucket  = "YOUR-TERRAFORM-STATE-BUCKET"
    key     = "staging/iam/terraform.tfstate"
    region  = "eu-west-1"
    encrypt = true
  }
}
