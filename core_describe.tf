resource "aws_iam_role" "terra_iam_for_lambda" {
    name = "terra_iam_for_lambda"
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

resource "aws_iam_role" "terra_iam_for_apigw" {
    name = "terra_iam_for_apigw"
    assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "apigateway.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "terra_lambda_iam_policy" {
    name = "terra_lambda_iam_policy"
    role = "${aws_iam_role.terra_iam_for_lambda.id}"
    policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ec2:Describe*",
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "terra_api_gateway_policy" {
    name = "terra_api_gateway_policy"
    role = "${aws_iam_role.terra_iam_for_apigw.id}"
    policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "lambda:InvokeFunction"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_lambda_function" "getInstancesLambda" {
    filename = "lambdas.zip"
    function_name = "core_describe"
    role = "${aws_iam_role.terra_iam_for_lambda.arn}"
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

resource "aws_api_gateway_method_response" "200" {
  rest_api_id = "${aws_api_gateway_rest_api.InstanceApi.id}"
  resource_id = "${aws_api_gateway_resource.instanceApiResource.id}"
  http_method = "${aws_api_gateway_method.instanceGetMethod.http_method}"
  status_code = "200"
}

resource "aws_api_gateway_integration" "instanceIntegration" {
  rest_api_id = "${aws_api_gateway_rest_api.InstanceApi.id}"
  resource_id = "${aws_api_gateway_resource.instanceApiResource.id}"
  http_method = "${aws_api_gateway_method.instanceGetMethod.http_method}"
  credentials = "${aws_iam_role.terra_iam_for_apigw.arn}"
  type = "AWS"
  uri = "arn:aws:apigateway:${var.run_region}:lambda:path/2015-03-31/functions/arn:aws:lambda:${var.run_region}:${var.account_id}:function:${aws_lambda_function.getInstancesLambda.function_name}/invocations"
  integration_http_method = "POST"
}

resource "aws_api_gateway_integration_response" "instanceIntegrationResponse" {
  rest_api_id = "${aws_api_gateway_rest_api.InstanceApi.id}"
  resource_id = "${aws_api_gateway_resource.instanceApiResource.id}"
  http_method = "${aws_api_gateway_method.instanceGetMethod.http_method}"
  status_code = "${aws_api_gateway_method_response.200.status_code}"
  response_templates = { 
    "application/json" = "$input.json('$')"
  }
  depends_on = [ "aws_api_gateway_integration.instanceIntegration" ]
}


resource "aws_api_gateway_deployment" "instanceDeployment" {
  depends_on = [ "aws_api_gateway_rest_api.InstanceApi", "aws_api_gateway_resource.instanceApiResource", "aws_api_gateway_method.instanceGetMethod", "aws_api_gateway_integration_response.instanceIntegrationResponse", "aws_api_gateway_integration.instanceIntegration", "aws_api_gateway_method_response.200"]

  rest_api_id = "${aws_api_gateway_rest_api.InstanceApi.id}"
  stage_name = "production"

  variables = {
    "answer" = "42"
  }
}