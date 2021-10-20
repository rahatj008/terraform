variable "event_rule_name" {
    default = "ScheduleLambda"
}
variable "event_rule_desc" {
    default = "Schedule Lambda Function"
}

variable "schedule_expression" {
    default = "cron(0 1 * * ? *)"
    # default = "rate(5 minutes)"
}

variable "programming_language" {
    default = "python3.8"
}

variable "lambda_function_name" {
    default = "check_foo"
}

variable "target_lambda_function" {
    default = "check_foo"
}

variable "target_sns" {
    default = "SendToSNS"
}

variable "sns_topic_name" {
    default = "aws-alerts"
}