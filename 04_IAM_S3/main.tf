provider "aws" {
  region = "ap-south-1"
}

resource "aws_iam_policy" "jk_tf_policy" {
    name = "jenkins_policy"
    path = "/"

    policy = jsonencode(
        {
            version = "2012-10-17",
            Statement = [
                {
                    Action = [
                        "ec2:*"
                    ],
                    Effect = "Allow",
                    Resource = "*"
                }
            ]
        }
    )
  
}

resource "aws_iam_role" "jk_tf_role" {
    name = "jenkins role"
    assume_role_policy = aws_iam_policy.jk_tf_policy.id
  
}


resource "aws_s3_bucket" "jk_tf_s3_bucket" {
  bucket = "unique-jk-tf-bucket"
}
