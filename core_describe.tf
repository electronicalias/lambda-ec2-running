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

resource "aws_api_gateway_resource" "instanceApiResource" {
  rest_api_id = "${aws_api_gateway_rest_api.InstanceApi.id}"
  parent_id = "${aws_api_gateway_rest_api.InstanceApi.root_resource_id}"
  path_part = "instances"
}

resource "aws_api_gateway_method" "instanceGetMethod" {
  rest_api_id = "${aws_api_gateway_rest_api.InstanceApi.id}"
  resource_id = "${aws_api_gateway_resource.instanceApiResource.id}"
  http_method = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "instanceIntegration" {
  rest_api_id = "${aws_api_gateway_rest_api.InstanceApi.id}"
  resource_id = "${aws_api_gateway_resource.instanceApiResource.id}"
  http_method = "${aws_api_gateway_method.instanceGetMethod.http_method}"
  type = "AWS"
  uri = "arn:aws:apigateway:${var.run_region}:lambda:path/2015-03-31/functions/arn:aws:lambda:${var.run_region}:632826021673:function:${aws_lambda_function.test_lambda.function_name}/invocations"
  integration_http_method = "GET"
}


resource "aws_api_gateway_deployment" "instanceDeployment" {
  depends_on = ["aws_api_gateway_method.instanceGetMethod"]

  rest_api_id = "${aws_api_gateway_rest_api.InstanceApi.id}"
  stage_name = "test"

  variables = {
    "answer" = "42"
  }
}