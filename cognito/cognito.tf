provider "aws" {
    region                  = "us-west-2"
    shared_credentials_file = "C:\\Users\\Waqar Ali\\.aws\\creds"
    profile                 = "breakout"
}

terraform {
  backend "s3" {
    bucket         = "terraform-breakout"
    key            = "data/cognito/terraform.tfstate"
    region         = "us-west-2"
  }
}

resource "aws_cognito_user_pool" "pool" {
  name = "breakout-pool"
  schema {
    attribute_data_type = "String"
    name                = "name"
    required            = true
  }
  schema {
    attribute_data_type = "String"
    name                = "email"
    required            = true
  }
}

resource "aws_cognito_user_pool_client" "client" {
  name            = "client"
  user_pool_id    = aws_cognito_user_pool.pool.id
  generate_secret = true
}

