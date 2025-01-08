locals {
    name = "${var.project_name}-${var.environment}-web"
    vpc-id = data.aws_ssm_parameter.vpc_id.value
    #mysql_sg_id = data.aws_ssm_parameter.mysql_sg_id.value
    public-subnet-id = split(",", data.aws_ssm_parameter.public_subnet_id.value)
    web-lb-sg-id = data.aws_ssm_parameter.web_lb_sg_id.value
    certificate-manager = data.aws_ssm_parameter.acm.value
    #db_subnet_group_id = data.aws_ssm_parameter.db_subnet_group_id.value
    #ami-id = data.aws_ami.ami_info.id.id


}