locals {
    name = "${var.project_name}-${var.environment}-${var.vpn_tags}"
    public-subnet-id =  split(",", data.aws_ssm_parameter.public_subnet_id.value)[0]
}