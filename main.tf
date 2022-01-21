terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}


/////////////////////////////////////////
// ------------ Provider ------------ //
///////////////////////////////////////

provider "aws" {
  # profile    = "default"
  region     = var.region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  # skip_credentials_validation = true
}
