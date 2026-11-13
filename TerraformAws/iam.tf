# resource "random_pet" "pet_name" {
#   length    = 3
#   separator = "-"
# }
# resource "aws_s3_bucket" "bucket" {
#   bucket = "${random_pet.pet_name.id}-bucket"
# }
#
# resource "aws_iam_user" "user_1" {
#   name = "arnab_1"
# }
#
# data "aws_iam_policy_document" "policy1" {
#   statement {
#     actions   = ["s3:ListAllMyBuckets"]
#     resources = ["arn:aws:s3:::*"]
#     effect = "Allow"
#   }
#   statement {
#     actions   = ["s3:*"]
#     resources = [aws_s3_bucket.bucket.arn]
#     effect = "Allow"
#   }
# }
#
# resource "aws_iam_policy" "policy" {
#   name        = "${random_pet.pet_name.id}-policy"
#   description = "My test policy"
#   policy = data.aws_iam_policy_document.policy1.json
# }
#
# resource "aws_iam_user_policy_attachment" "attachment" {
#   user       = aws_iam_user.user_1.name
#   policy_arn = aws_iam_policy.policy.arn
# }

resource "aws_iam_role" "lambda_exec" {
  name = "serverless_lambda"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Sid    = ""
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}


