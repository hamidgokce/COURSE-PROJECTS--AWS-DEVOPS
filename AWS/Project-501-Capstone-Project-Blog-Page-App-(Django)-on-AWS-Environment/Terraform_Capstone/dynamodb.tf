
resource "aws_dynamodb_table" "aws-capstone-dynamodb-table" {
  name           = "awscapstoneDynamo"
  billing_mode   = "PROVISIONED"
  read_capacity  = var.dynamo_read_capacity
  write_capacity = var.dynamo_write_capacity
  hash_key       = "id"

  attribute {
    name = "id"
    type = "S"
  }

  tags = {
    Name        = "aws_capstone-dynamodb-table"
  }
}