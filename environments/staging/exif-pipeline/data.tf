# Read outputs from storage component via remote state
data "terraform_remote_state" "storage" {
  backend = "s3"

  config = {
    bucket = "YOUR-TERRAFORM-STATE-BUCKET"
    key    = "staging/storage/terraform.tfstate"
    region = "eu-west-1"
  }
}
