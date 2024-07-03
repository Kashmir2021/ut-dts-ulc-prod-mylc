terraform {
  backend "s3" {
    profile = "<profile name in here>"
    bucket  = "ut-ulc-mylc-prod-terraform-state"
    key     = "applications/terraform.tfstate"
    region  = "us-west-2"
    encrypt = true
  }
}
provider "aws" {
  region  = "us-west-2"
  profile = "<profile name in here>"
}
