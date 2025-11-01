terraform {
  backend "s3" {
    # Update these values for your environment
    bucket  = "YOUR-TERRAFORM-STATE-BUCKET"
    key     = "staging/exif-pipeline/terraform.tfstate"
    region  = "eu-west-1"
    encrypt = true
  }
}
