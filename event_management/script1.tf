provider "aws" {
    region                  = "us-west-2"
    shared_credentials_file = "C:\\Users\\Waqar Ali\\.aws\\creds"
    profile                 = "breakout"
  #   aws_access_key_id = AKIA3KSNNT5A7J6CCKFJ
  # aws_secret_access_key = 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
}

provider "archive" {}

resource "aws_cloudwatch_event_rule" "every_five_minutes" {
    name = var.event_rule_name
    description = var.event_rule_desc
    schedule_expression = var. schedule_expression  
}

data "archive_file" "lambda" {
  type        = "zip"
  source_file = "D:\\terraform\\event_management\\python\\main.py"
  output_path = "D:\\terraform\\event_management\\python\\main.py.zip"
}

resource "aws_iam_role" "role_lambda" {
  name = "roleLambda"

  assume_role_policy = <<-POLICY
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Principal": {
          "Service": "lambda.amazonaws.com"
        },
        "Effect": "Allow",
        "Sid": ""
      }
    ]
  }
  POLICY
}

resource "aws_lambda_function" "check_foo" {
    filename = data.archive_file.lambda.output_path
    function_name = var.lambda_function_name
    runtime           =  var.programming_language
    role  = aws_iam_role.role_lambda.arn
    handler = "index.handler"
}

resource "aws_cloudwatch_event_target" "check_foo_every_five_minutes" {
    rule = "${aws_cloudwatch_event_rule.every_five_minutes.name}"
    target_id = var.target_lambda_function
    arn = "${aws_lambda_function.check_foo.arn}"
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_check_foo" {
    statement_id = "AllowExecutionFromCloudWatch"
    action = "lambda:InvokeFunction"
    function_name = "${aws_lambda_function.check_foo.function_name}"
    principal = "events.amazonaws.com"
    source_arn = "${aws_cloudwatch_event_rule.every_five_minutes.arn}"
}



data "aws_iam_policy_document" "sns_topic_policy" {
  statement {
    effect  = "Allow"
    actions = ["SNS:Publish"]

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }

    resources = [aws_sns_topic.aws_alerts.arn]
  }
}


resource "aws_cloudwatch_event_target" "sns" {
  rule      = aws_cloudwatch_event_rule.every_five_minutes.name
  target_id = var.target_sns
  arn       = aws_sns_topic.aws_alerts.arn
}

resource "aws_sns_topic" "aws_alerts" {
  name = var.sns_topic_name
}

resource "aws_sns_topic_policy" "default" {
  arn    = aws_sns_topic.aws_alerts.arn
  policy = data.aws_iam_policy_document.sns_topic_policy.json
}

resource "aws_sns_topic_subscription" "email-target" {
  topic_arn = aws_sns_topic.aws_alerts.arn
  protocol  = "email"
  endpoint  = "abc@gmail.com"
}