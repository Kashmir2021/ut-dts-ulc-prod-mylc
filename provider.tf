terraform {
  backend "s3" {
    profile = "ulc-dev"
    bucket  = "ut-ulc-dev-terraform-state"
    key     = "applications/terraform.tfstate"
    region  = "us-west-2"
    encrypt = true
  }
}
provider "aws" {
  region  = "us-west-2"
  profile = "ulc-dev"
}
