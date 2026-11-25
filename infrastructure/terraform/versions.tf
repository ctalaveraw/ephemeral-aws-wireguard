terraform {
  required_version = "~> 1.16.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

# Fail before provisioning if the caller is authenticated to the wrong account.
provider "aws" {
  region              = var.aws_region
  allowed_account_ids = [var.expected_account_id]

  default_tags {
    tags = local.common_tags
  }
}
