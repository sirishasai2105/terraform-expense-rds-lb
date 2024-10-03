locals {
    name = "${var.project_name}-${var.environment}-${var.bastion_tags}"
    bastion-id = data.aws_ssm_parameter.bastion_sg_id.value
    public-subnet-id = split(",", data.aws_ssm_parameter.public_subnet_id.value)[0]
    #ami-id = data.aws_ami.ami_info.id.id
}