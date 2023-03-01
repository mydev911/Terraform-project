provider "aws" {
  region = "us-west-2"
}

resource "aws_s3_bucket" "bucket" {
  bucket = "my-bucket"
}

resource "aws_iam_role" "lambda_execution_role" {
  name = "lambda_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "s3_access_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  role       = aws_iam_role.lambda_execution_role.name
}

data "archive_file" "lambda_function_zip" {
  type        = "zip"
  source_file = "lambda_function.py"
  output_path = "delete_files_function.zip"
}

resource "aws_lambda_function" "delete_files_function" {
  filename      = data.archive_file.lambda_function_zip.output_path
  function_name = "delete_files_function"
  role          = aws_iam_role.lambda_execution_role.arn
  handler       = "index.handler"
  runtime       = "python3.8"

  environment = {
    variables = {
      BUCKET_NAME = aws_s3_bucket.bucket.bucket
    }
  }
}

resource "aws_cloudwatch_event_rule" "delete_files_rule" {
  name = "delete_files_rule"

  schedule_expression = "rate(30 minutes)"

  targets = [
    {
      arn = aws_lambda_function.delete_files_function.arn,
      id  = "delete_files_function_target"
    }
  ]
}
