provider "aws" {
    region                  = "us-west-2"
    shared_credentials_file = "C:\\Users\\Waqar Ali\\.aws\\creds"
    profile                 = "breakout"
}

terraform {
  backend "s3" {
    bucket         = "terraform-breakout"
    key            = "data/autoscaling/terraform.tfstate"
    region         = "us-west-2"
  }
}

resource "aws_autoscaling_group" "platform-asg" {
  name = "Platform-AG"
  min_size             = 1
  desired_capacity     = 1
  max_size             = 10
  health_check_grace_period = 300
  target_group_arns = [
    "arn:aws:elasticloadbalancing:us-west-2:778625195841:targetgroup/VPC-TG/394681c3e1ccec29"
  ]

  launch_configuration = "terra-platform 23June2021 0118PM"
  vpc_zone_identifier = ["subnet-09391cbab85ea1349", "subnet-0fd53ed4152990cb3"]

  enabled_metrics = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupTotalInstances"
  ]

  metrics_granularity="1Minute"

  termination_policies = ["OldestInstance"]

  tag {
    key                 = "Name"
    value               = "web"
    propagate_at_launch = true
  }
}

