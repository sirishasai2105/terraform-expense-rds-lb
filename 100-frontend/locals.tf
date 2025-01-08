locals {
    name = "${var.project_name}-${var.environment}-frontend"
    public-subnet-id =  split(",", data.aws_ssm_parameter.public_subnet_id.value)[0]
    frontend-sg-id = data.aws_ssm_parameter.frontend_sg_id.value
    vpc-id = data.aws_ssm_parameter.vpc_id.value
    listener-arn = data.aws_ssm_parameter.listener_arn.value
}