locals {
    name = "${var.project_name}-${var.environment}-${var.app_lb_tags}"
    #mysql_sg_id = data.aws_ssm_parameter.mysql_sg_id.value
    private-subnet-id = split(",", data.aws_ssm_parameter.private_subnet_id.value)
    app-lb-sg-id = data.aws_ssm_parameter.app_lb_subnet_id.value
    #db_subnet_group_id = data.aws_ssm_parameter.db_subnet_group_id.value
    #ami-id = data.aws_ami.ami_info.id.id


}