output "aws_lambda_arn" {
    value = "${aws_lambda_function.check_foo.arn}"
}