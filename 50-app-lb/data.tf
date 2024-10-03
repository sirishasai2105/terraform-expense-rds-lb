data "aws_ssm_parameter" "vpc_id" {
  name = "/expense/dev/vpc_id"
}

data "aws_ssm_parameter" "private_subnet_id" {
    name  = "/expense/dev/private_subnet_ids"
}

data "aws_ssm_parameter" "app_lb_subnet_id" {
    name  = "/${var.project_name}/${var.environment}/app_lb_sg_id"
}