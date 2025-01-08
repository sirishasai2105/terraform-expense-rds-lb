data "aws_ssm_parameter" "vpc_id" {
  name = "/expense/dev/vpc_id"
}

data "aws_ssm_parameter" "public_subnet_id" {
    name  = "/expense/dev/public_subnet_ids"
}

data "aws_ssm_parameter" "app_lb_subnet_id" {
    name  = "/${var.project_name}/${var.environment}/app_lb_sg_id"
}

data "aws_ssm_parameter" "web_lb_sg_id" {
  name  = "/${var.project_name}/${var.environment}/web_lb_sg_id"

}

data "aws_ssm_parameter" "acm" {
  name  = "/${var.project_name}/${var.environment}/acm"
}
