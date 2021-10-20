provider "aws" {
    region                  = "us-west-2"
    shared_credentials_file = "C:\\Users\\Waqar Ali\\.aws\\creds"
    profile                 = "breakout"
}

# terraform {
#   backend "s3" {
#     bucket         = "terraform-breakout"
#     key            = "data/launch_configuration/terraform.tfstate"
#     region         = "us-west-2"
#   }
# }

resource "aws_ami_from_instance" "production_ami" {
    #name = "terra-platform ${formatdate("DDMMMYYYY hhmm ZZZ", timestamp())}"
    name = var.new_build_name
    source_instance_id = var.pre_production_instance_id
}

resource "aws_launch_configuration" "production_lc" {
    name = var.new_build_name
    instance_type = var.ec2_type
    key_name = "Breakfree"
    image_id = aws_ami_from_instance.production_ami.id
    security_groups = [var.breakout_security_group]
    associate_public_ip_address = false

    root_block_device {
        volume_type           = "standard"
        volume_size           = 30
        delete_on_termination = true
        encrypted             = false #block is not encrypted
    }
    # ebs_block_device {
    #     device_name = "ebs-device"
    #     encrypted   = false #block is not encrypted
    # }

    lifecycle {
        create_before_destroy = true
    }
    
}

output "ami_id" {
    value = aws_launch_configuration.production_lc.id
}

output "launch_configuration_id" {
    value = aws_launch_configuration.production_lc.id
}

output "curent_time" {
    value = formatdate("DD MMM YYYY hh:mm ZZZ", timestamp())
}