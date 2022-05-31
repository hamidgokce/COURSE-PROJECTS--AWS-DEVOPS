resource "aws_iam_instance_profile" "test_profile" {
  name = "test_profile"
  role = aws_iam_role.aws_capstone_s3_full_access.name
}


resource "aws_iam_role" "aws_capstone_s3_full_access" {
  name = "aws_capstone_s3_full_access"
  path = "/"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    tag-key = "aws_capstone_s3_full_access"
  }
}

resource "aws_iam_role_policy_attachment" "s3_full_access" {
  role       = aws_iam_role.aws_capstone_s3_full_access.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_role_policy_attachment" "SSM_management" {
  role       = aws_iam_role.aws_capstone_s3_full_access.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}


resource "aws_iam_role" "aws_capstone_lambda_role" {
  name = "aws_capstone_lambda_role"
  path = "/"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    tag-key = "aws_capstone_lambda_role"
  }
}


resource "aws_iam_role_policy_attachment" "DynamoDB_full_access" {
  role       = aws_iam_role.aws_capstone_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}

resource "aws_iam_role_policy_attachment" "lambda_s3_full_access" {
  role       = aws_iam_role.aws_capstone_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_role_policy_attachment" "Network_admin_policy" {
  role       = aws_iam_role.aws_capstone_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/job-function/NetworkAdministrator"
}