data "aws_ssm_parameter" "vpc_id" {
  name = "/expense/dev/vpc_id"
}

data "aws_ssm_parameter" "public_subnet_id" {
    name  = "/expense/dev/public_subnet_ids"
}

data "aws_ssm_parameter" "frontend_sg_id" {
    name  = "/${var.project_name}/${var.environment}/frontend_sg_id" 
}

data "aws_ssm_parameter" "listener_arn" {
  name  = "/${var.project_name}/${var.environment}/web-lb-listerner-arn"
}


data "aws_ami" "ami_info" {
  most_recent = true
  owners      = ["973714476881"]


  filter {
    name   = "name"
    values = ["RHEL-9-DevOps-Practice"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

}