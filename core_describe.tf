resource "aws_iam_role_policy" "test_policy" {
    name = "test_policy"
    role = "${aws_iam_role.iam_for_lambda.id}"
    policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ec2:Describe*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role" "iam_for_lambda" {
    name = "iam_for_lambda"
    assume_role_policy = <<EOF
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
EOF
}

resource "aws_lambda_function" "test_lambda" {
    filename = "lambdas.zip"
    function_name = "core_describe"
    role = "${aws_iam_role.iam_for_lambda.arn}"
    handler = "core_describe.lambda_handler"
    source_code_hash = "${base64sha256(file("lambdas.zip"))}"
    runtime = "python2.7"
}

resource "aws_api_gateway_rest_api" "InstanceApi" {
  name = "InstanceApi"
  description = "Terraform created API by psmith"
}