terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }

  backend "s3" {
    bucket = "dummy-bucket"                 # placeholder; will be overridden in CLI
    key    = "dummy/path/terraform.tfstate" # placeholder
    region = "us-east-1"                    # placeholder
  }
}