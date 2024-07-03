output "beanstalk_ec2_role_name" {
  description = "Name that identifies the ec2 beanstalk role"
  value = aws_iam_role.beanstalk_ec2.name
}
