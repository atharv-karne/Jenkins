provider "aws" {
  region = "ap-south-1"
}

resource "aws_iam_policy" "jk_tf_policy" {
  name   = "jenkins-policy"
  policy = jsonencode({
    version = "2012-10-17",
    Statement = [
      {
        Action   = [
          "ec2:*"
        ]
        Effect   = "Allow"
        Resource = ["*"]
      }
    ]
  })
}

resource "aws_iam_role" "jk_tf_role" {
  name = "jenkins-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action    = "sts:AssumeRole",
        Effect    = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "jk_tf_policy_attachment" {
  policy_arn = aws_iam_policy.jk_tf_policy.arn
  role      = aws_iam_role.jk_tf_role.name
}

resource "aws_s3_bucket" "jk_tf_s3_bucket" {
  bucket = "unique-jk-tf-bucket-2323" # 
}
