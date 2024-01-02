# Configure the AWS Provider
provider "aws" {
  region = "eu-west-2"
  profile = "dev"
}
locals {
  name = "sophie"
}

