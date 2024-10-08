locals {
    name = "${var.project_name}-${var.environment}-backend"
    private-subnet-id =  split(",", data.aws_ssm_parameter.private_subnet_id.value)[0]
    backend-sg-id = data.aws_ssm_parameter.backend_sg_id.value
    vpc-id = data.aws_ssm_parameter.vpc_id.value
}