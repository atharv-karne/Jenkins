provider "aws" {
  region = "ap-south-1"
}

#Bucket for csv
resource "aws_s3_bucket" "tf-bucket" {
  bucket = "jk-tf-bucket-lambda-read"
  force_destroy = true
}


#Assume role policy for lambda
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]


    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}


#Creating policy for lambda
resource "aws_iam_policy" "lambda_s3_read_policy" {
  name = "custom_lambda_read_s3_policy"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:ListBucket"
        ],
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:GetObject"
        ],
        "Resource" : ["${aws_s3_bucket.tf-bucket.arn}/*"]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        "Resource" : "arn:aws:logs:*:*:*"

      }
    ]
    }
  )
}





#Creating role
resource "aws_iam_role" "aws_execution_role" {
  name               = "lambda_s3_read_role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}


#Policy attachment to role
resource "aws_iam_policy_attachment" "attach_policy_to_lambda" {
  name       = "attachment"
  roles      = [aws_iam_role.aws_execution_role.name]
  policy_arn = aws_iam_policy.lambda_s3_read_policy.arn
}



#///////////////////////////////////////////////////////////////////////////////////////////////////////

#Creating lambda function

resource "aws_lambda_function" "lambda_read_s3" {
  function_name = "reads3"
  filename      = "fun.zip"
  role          = aws_iam_role.aws_execution_role.arn
  handler       = "reads3.lambda_handler"
  runtime       = "python3.8"
  timeout       = 45

}

#//////////////////////////////////////////////////////////////////////////////////////////////////////


#Allowing lambda to be invoked by s3

resource "aws_lambda_permission" "allow_s3" {
    action = "lambda:InvokeFunction"
    function_name = aws_lambda_function.lambda_read_s3.function_name
    principal = "s3.amazonaws.com"
    source_arn = aws_s3_bucket.tf-bucket.arn

}



#//////////////////////////////////////////////////////////////////////////////////////////////////////



#Creating trigger to s3 for this lambda function
resource "aws_s3_bucket_notification" "s3_push_notification" {
  bucket = aws_s3_bucket.tf-bucket.id
  lambda_function {
    lambda_function_arn = aws_lambda_function.lambda_read_s3.arn
    filter_suffix = ".csv"
    events              = ["s3:ObjectCreated:*"]

  }

}



