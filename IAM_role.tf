# IAM Role for EC2 to Access S3
resource "aws_iam_role" "jenkins_ec2_role" {
  name = "jenkins-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

# IAM Policy to Allow S3 Read Access
resource "aws_iam_policy" "jenkins_s3_policy" {
  name        = "jenkins-s3-read-policy"
  description = "Allows EC2 to read backup from S3"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ],
        Resource = [
          "arn:aws:s3:::jenkins-config-terraform",
          "arn:aws:s3:::jenkins-config-terraform/*"
        ]
      }
    ]
  })
}

# Attach Policy to Role 
resource "aws_iam_role_policy_attachment" "attach" {
  role       = aws_iam_role.jenkins_ec2_role.name
  policy_arn = aws_iam_policy.jenkins_s3_policy.arn
}

# Create Instance Profile & Attach to EC2
resource "aws_iam_instance_profile" "jenkins_instance_profile" {
  name = "jenkins-instance-profile"
  role = aws_iam_role.jenkins_ec2_role.name
}