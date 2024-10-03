locals {
    name = "${var.project_name}-${var.environment}-${var.rds_tags}"
    mysql_sg_id = data.aws_ssm_parameter.mysql_sg_id.value
    db_subnet_group_id = data.aws_ssm_parameter.db_subnet_group_id.value
    #ami-id = data.aws_ami.ami_info.id.id
}