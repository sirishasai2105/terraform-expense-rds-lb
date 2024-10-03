resource "aws_ssm_parameter" "bastion_sg_id" {
  name  = "/${var.project_name}/${var.environment}/bastion_sg_id"
  type  = "String"
  value = module.bastion_security_group.sg_id
  # lifecycle {
  #   prevent_destroy = true  # Prevents accidental deletion
  # }
}

resource "aws_ssm_parameter" "mysql_sg_id" {
  name  = "/${var.project_name}/${var.environment}/mysql_sg_id"
  type  = "String"
  value = module.mysql_security_group.sg_id
  # lifecycle {
  #   prevent_destroy = true  # Prevents accidental deletion
  # }

}

resource "aws_ssm_parameter" "backend_sg_id" {
  name  = "/${var.project_name}/${var.environment}/backend_sg_id"
  type  = "String"
  value = module.backend_security_group.sg_id
  # lifecycle {
  #   prevent_destroy = true  # Prevents accidental deletion
  # }

}

resource "aws_ssm_parameter" "frontend_sg_id" {
  name  = "/${var.project_name}/${var.environment}/frontend_sg_id"
  type  = "String"
  value = module.frontend_security_group.sg_id
  # lifecycle {
  #   prevent_destroy = true  # Prevents accidental deletion
  # }
}

resource "aws_ssm_parameter" "ansible_sg_id" {
  name  = "/${var.project_name}/${var.environment}/ansible_sg_id"
  type  = "String"
  value = module.ansible_security_group.sg_id
  # lifecycle {
  #   prevent_destroy = true  # Prevents accidental deletion
  # }
}

resource "aws_ssm_parameter" "app_lb_sg_id" {
  name  = "/${var.project_name}/${var.environment}/app_lb_sg_id"
  type  = "String"
  value = module.app-lb.sg_id
  # lifecycle {
  #   prevent_destroy = true  # Prevents accidental deletion
  # }
}