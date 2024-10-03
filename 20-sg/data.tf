data "aws_ssm_parameter" "vpc_id" {
  name = "/expense/dev/vpc_id"
}