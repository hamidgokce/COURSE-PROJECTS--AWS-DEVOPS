resource "aws_s3_bucket_policy" "aws_capstone_bucket_policy" {
  bucket = aws_s3_bucket.aws_capstone_bucket_failover.id

  # Terraform's "jsonencode" function converts a
  # Terraform expression's result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "MYBUCKETPOLICY"
    Statement = [
      {
        Sid       = "PublicReadforBucket"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource = [
          aws_s3_bucket.aws_capstone_bucket_failover.arn,
          "${aws_s3_bucket.aws_capstone_bucket_failover.arn}/*",
        ]
      }
    ]
  })
}

resource "aws_s3_bucket" "aws_capstone_bucket_failover" {
  bucket = local.web_site_name
  acl    = "public-read"
  website {
    index_document = "index.html"
  }
  tags = local.tags
}

resource "aws_s3_bucket" "aws_capstone_bucket" {
  bucket = local.bucket_name
  acl    = "public-read"
  tags = local.tags
}


resource "null_resource" "wait_for_lambda_trigger" {
  depends_on   = [aws_lambda_permission.s3_trigger]
  provisioner "local-exec" {
    command = "sleep 3m"
  }
}

resource "aws_s3_bucket_notification" "bucket_create_notification" {
  bucket = aws_s3_bucket.aws_capstone_bucket.id
  depends_on   = [null_resource.wait_for_lambda_trigger]
  
  lambda_function {
    lambda_function_arn = aws_lambda_function.s3_to_dynamo_Lambda.arn
    events              = ["s3:ObjectCreated:*", "s3:ObjectRemoved:*"]
    filter_prefix       = "media/"
  }
}
