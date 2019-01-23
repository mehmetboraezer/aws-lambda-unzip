provider "aws" {
  region = "${var.aws_region}"
}

variable "aws_region"     { default = "us-west-2" }

variable "target_bucket"  { }

resource "aws_lambda_function" "unzip_lambda_lambda_function" {
  role             = "${aws_iam_role.unzip_lambda_exec_role.arn}"
  handler          = "unzip_lambda.lambda_handler"
  runtime          = "python3.6"
  filename         = "unzip_lambda.zip"
  function_name    = "unzip_lambda"
  source_code_hash = "${base64sha256(file("unzip_lambda.zip"))}"

  timeout          = 900 // 15 minutes (it's maximum for lambdas)

  environment {
    variables = {
      aws_region = "${var.aws_region}"
    }
  }
}

resource "aws_iam_role" "unzip_lambda_exec_role" {
  name        = "unzip_lambda_exec"
  path        = "/"
  description = "Allows Lambda Function to call AWS services on your behalf."
  assume_role_policy = "${data.aws_iam_policy_document.instance-assume-role-policy.json}"
}

resource "aws_iam_role_policy" "unzip_lambda_exec_role_policy" {
  role = "${aws_iam_role.unzip_lambda_exec_role.id}"
  policy = "${data.aws_iam_policy_document.unzip_lambda_role_policy.json}"
}

data "aws_iam_policy_document" "instance-assume-role-policy" {
  statement {
    effect = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = [ "lambda.amazonaws.com" ]
    }
  }
}

data "aws_iam_policy_document" "unzip_lambda_role_policy" {
  statement {
    effect = "Allow"
    actions = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"]
    resources = ["arn:aws:s3:::${var.target_bucket}*"]
  }
}

resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.unzip_lambda_lambda_function.arn}"
  principal     = "s3.amazonaws.com"
  source_arn    = "${data.aws_s3_bucket.target_bucket.arn}"
}

data "aws_s3_bucket" "target_bucket" {
  bucket = "${var.target_bucket}"
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = "${var.target_bucket}"

  lambda_function {
    lambda_function_arn = "${aws_lambda_function.unzip_lambda_lambda_function.arn}"
    events              = ["s3:ObjectCreated:*"]
    filter_suffix       = ".zip"
  }
}
