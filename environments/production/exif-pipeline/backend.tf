terraform {
  backend "s3" {
    # Update these values for your environment
    bucket  = "YOUR-TERRAFORM-STATE-BUCKET"
    key     = "production/exif-pipeline/terraform.tfstate"
    region  = "eu-west-2"
    encrypt = true
  }
}
