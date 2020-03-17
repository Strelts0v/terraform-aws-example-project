provider "aws" {
  version = "~> 2.52"
  region  = "eu-central-1"
}

terraform {
  backend "s3" {
    bucket  = "terraform-example-project-state"
    key     = "dev/terraform.tfstate"
    encrypt = "true"
    region  = "eu-central-1"
  }
}
