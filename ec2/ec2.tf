provider "aws" {
  region                  = "us-west-2"
  shared_credentials_file = "C:\\Users\\Waqar Ali\\.aws\\creds"
  profile                 = "breakout"
}

terraform {
  backend "s3" {
    bucket         = "terraform-breakout"
    key            = "data/ec2/terraform.tfstate"
    region         = "us-west-2"
  }
}

resource "aws_instance" "ec2_mgmt" {
  instance_type = "t4g.medium"
  ami = "ami-01f7fca76e13fcbca"
  disable_api_termination = false
  ebs_optimized = false
  root_block_device {
    volume_size = "20"
  }
  tags = {
    "Name" = "PreProductionT4g"
  }
}

locals {
	http_ports = [80, 443]

  ingress_ssh_rules = [{
		port        = 22
		description = "Port 22"
	},
	{
		port        = 9022
		description = "Port 9022"
	}]
}

resource "aws_security_group" "custom_terraform_test_1_sg" {
  name = "CustomTerraformTest1"
  description = "Allow ssh"
  dynamic "ingress" {
		for_each = local.http_ports

		content {
			from_port   = ingress.value
			to_port     = ingress.value
			protocol    = "tcp"
			cidr_blocks = ["0.0.0.0/0"]
		}
    # for_each = local.ingress_ssh_rules

		# content {
		# 	description = ingress.value.description
		# 	from_port   = ingress.value.port
		# 	to_port     = ingress.value.port
		# 	protocol    = "tcp"
		# 	cidr_blocks = ["0.0.0.0/0"]
		# }
	}
  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port = 0
    to_port = 0
    protocol = "-1"
  }
}

output "security_group_id" {
  value = aws_security_group.custom_terraform_test_1_sg.id
}