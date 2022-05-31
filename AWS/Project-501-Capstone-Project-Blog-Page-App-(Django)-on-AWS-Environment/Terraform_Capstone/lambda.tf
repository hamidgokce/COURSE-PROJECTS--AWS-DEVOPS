resource "aws_lambda_function" "s3_to_dynamo_Lambda" {
  filename      = "lambda_s3_dynamo.py.zip"
  function_name = "awscapstonelambda"
  role          = aws_iam_role.aws_capstone_lambda_role.arn
  handler       = "lambda_s3_dynamo.lambda_handler"
  # The name of handler has to start with filename than .lambda_handler

  # The filebase64sha256() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the base64sha256() function and the file() function:
  # source_code_hash = "${base64sha256(file("lambda_function_payload.zip"))}"
  # source_code_hash = filebase64sha256("lambda_s3_dynamo.zip")

  runtime = "python3.8"
  
}

resource "aws_lambda_permission" "s3_trigger" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.s3_to_dynamo_Lambda.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.aws_capstone_bucket.arn
}