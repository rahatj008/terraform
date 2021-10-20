provider "aws" {
    region                  = "us-west-2"
    shared_credentials_file = "C:\\Users\\Waqar Ali\\.aws\\creds"
    profile                 = "golpik"
}

# terraform {
#   backend "s3" {
#     bucket         = "terraform-breakout"
#     key            = "data/amplify/terraform.tfstate"
#     region         = "us-west-2"
#   }
# }

resource "aws_amplify_app" "first_app" {
  name       = "First App"
  custom_rule {
    source = "/<*>"
    status = "404"
    target = "/index.html"
  }

#   environment_variables = {
#     ENV = "test"
#   }
}