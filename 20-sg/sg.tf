module "mysql_security_group" {
    source =  "../../terraform-aws-security-group"
    project_name = var.project_name
    environment = var.environment
    # sg_tags = "mysql"
    sg_tags = var.mysql_sg_tags
    vpc_id = data.aws_ssm_parameter.vpc_id.value
}

module "backend_security_group" {
    source =  "../../terraform-aws-security-group"
    project_name = var.project_name
    environment = var.environment
    # sg_tags = "backend"
    sg_tags = var.backend_sg_tags
    vpc_id = data.aws_ssm_parameter.vpc_id.value
}

module "frontend_security_group" {
    source =  "../../terraform-aws-security-group"
    project_name = var.project_name
    environment = var.environment
    # sg_tags = "backend"
    sg_tags = var.database_sg_tags
    vpc_id = data.aws_ssm_parameter.vpc_id.value
}

module "bastion_security_group" {
    source =  "../../terraform-aws-security-group"
    project_name = var.project_name
    environment = var.environment
    # sg_tags = "mysql"
    sg_tags = var.bastion_sg_tags
    vpc_id = data.aws_ssm_parameter.vpc_id.value
}

module "ansible_security_group" {
    source =  "../../terraform-aws-security-group"
    project_name = var.project_name
    environment = var.environment
    # sg_tags = "mysql"
    sg_tags = var.ansible_sg_tags
    vpc_id = data.aws_ssm_parameter.vpc_id.value
}

module "app-lb" {
    source =  "../../terraform-aws-security-group"
    project_name = var.project_name
    environment = var.environment
    # sg_tags = "mysql"
    sg_tags = var.app_lb_tags 
    vpc_id = data.aws_ssm_parameter.vpc_id.value
}

module "web-lb" {
    source =  "../../terraform-aws-security-group"
    project_name = var.project_name
    environment = var.environment
    # sg_tags = "mysql"
    sg_tags = var.web_lb_tags 
    vpc_id = data.aws_ssm_parameter.vpc_id.value
}

module "vpn_sg" {
    source =  "../../terraform-aws-security-group"
    project_name = var.project_name
    environment = var.environment
    # sg_tags = "mysql"
    sg_tags = var.vpn_tags 
    vpc_id = data.aws_ssm_parameter.vpc_id.value
}

resource "aws_security_group_rule" "mysql_from_backend" {
  type = "ingress"
  security_group_id = module.mysql_security_group.sg_id
  from_port         = 3306
  protocol       = "tcp"
  to_port           = 3306
  source_security_group_id = module.backend_security_group.sg_id
}

# resource "aws_security_group_rule" "backend_from_frontend" {
#   type = "ingress"
#   security_group_id = module.backend_security_group.sg_id
#   from_port         = 8080
#   protocol       = "tcp"
#   to_port           = 8080
#   source_security_group_id = module.frontend_security_group.sg_id
# }

# resource "aws_security_group_rule" "frontend_from_public" {
#   type              = "ingress"
#   from_port         = 80
#   to_port           = 80
#   protocol          = "tcp"
#   cidr_blocks       = ["0.0.0.0/0"]
#   security_group_id = module.frontend_security_group.sg_id
# }

#bastion accepting from mysql
resource "aws_security_group_rule" "bastion_from_mysql" {
  type = "ingress"
  security_group_id = module.mysql_security_group.sg_id
  from_port         = 22
  protocol       = "tcp"
  to_port           = 22
  source_security_group_id = module.bastion_security_group.sg_id 
  
}

#backend accepting from bastion
resource "aws_security_group_rule" "bastion_from_backend" {
  type = "ingress"
  security_group_id = module.backend_security_group.sg_id
  from_port         = 22
  protocol       = "tcp"
  to_port           = 22
  source_security_group_id = module.bastion_security_group.sg_id 
  
}

#frontend accepting from bastion
resource "aws_security_group_rule" "bastion_from_frontend" {
  type = "ingress"
  security_group_id = module.frontend_security_group.sg_id
  from_port         = 22
  protocol       = "tcp"
  to_port           = 22
  source_security_group_id = module.bastion_security_group.sg_id 
  
}

#bastion accepting from public
resource "aws_security_group_rule" "bastion_from_public" {
  type = "ingress"
  security_group_id = module.bastion_security_group.sg_id
  from_port         = 22
  protocol       = "tcp"
  to_port           = 22
  cidr_blocks = ["0.0.0.0/0"]
  
}

# mysql accepting from ansible 
resource "aws_security_group_rule" "ansible_from_mysql" { 
  type = "ingress"
  security_group_id = module.mysql_security_group.sg_id
  from_port         = 22
  protocol       = "tcp"
  to_port           = 22
  source_security_group_id = module.ansible_security_group.sg_id 
  
}

#backend accepting from ansible
resource "aws_security_group_rule" "ansible_from_backend" { 
  type = "ingress"
  security_group_id =  module.backend_security_group.sg_id
  from_port         = 22
  protocol       = "tcp"
  to_port           = 22
  source_security_group_id = module.ansible_security_group.sg_id
  
}

#frontend accepting from ansible
resource "aws_security_group_rule" "ansible_from_frontend" {
  type = "ingress"
  security_group_id = module.frontend_security_group.sg_id
  from_port         = 22
  protocol       = "tcp"
  to_port           = 22
  source_security_group_id = module.ansible_security_group.sg_id 
  
}

#ansible accepting from public
resource "aws_security_group_rule" "ansible_from_public" {
  type = "ingress"
  security_group_id = module.ansible_security_group.sg_id
  from_port         = 22
  protocol       = "tcp"
  to_port           = 22
  cidr_blocks = ["0.0.0.0/0"]
  
}

# application load balancer accepting from frontend
resource "aws_security_group_rule" "app_lb_from_frontend" {
  type = "ingress"
  security_group_id = module.app-lb.sg_id
  from_port         = 80
  protocol       = "tcp"
  to_port           = 80
  source_security_group_id = module.frontend_security_group.sg_id
  
}

# application load balancer accepting from bastion
resource "aws_security_group_rule" "app_lb_from_bastion" {
  type = "ingress"
  security_group_id = module.app-lb.sg_id
  from_port         = 80
  protocol       = "tcp"
  to_port           = 80
  source_security_group_id = module.bastion_security_group.sg_id
  
}
#backend accepting connections from app-lb
resource "aws_security_group_rule" "backend_from_app_lb" {
  type = "ingress"
  security_group_id = module.backend_security_group.sg_id
  from_port         = 8080
  protocol       = "tcp"
  to_port           = 8080
  source_security_group_id = module.app-lb.sg_id
  
}

#opening 4 different ports for vpn
resource "aws_security_group_rule" "vpn_from_public" {
  type = "ingress"
  security_group_id = module.vpn_sg.sg_id
  from_port         = 22
  protocol       = "tcp"
  to_port           = 22
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "vpn_from_443" {
  type = "ingress"
  security_group_id = module.vpn_sg.sg_id
  from_port         = 443
  protocol       = "tcp"
  to_port           = 443
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "vpn_from_943" {
  type = "ingress"
  security_group_id = module.vpn_sg.sg_id
  from_port         = 943
  protocol       = "tcp"
  to_port           = 943
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "vpn_from_1194" {
  type = "ingress"
  security_group_id = module.vpn_sg.sg_id
  from_port         = 1194
  protocol       = "tcp"
  to_port           = 1194
  cidr_blocks = ["0.0.0.0/0"]
}

#vpn accepting connections from backend lb
resource "aws_security_group_rule" "vpn_from_backendlb" {
  type = "ingress"
  security_group_id = module.app-lb.sg_id
  from_port         = 80
  protocol       = "tcp"
  to_port           = 80
  source_security_group_id = module.vpn_sg.sg_id
}
#vpn accepting connections from backend 
resource "aws_security_group_rule" "vpn_from_backend" {
  type = "ingress"
  security_group_id = module.backend_security_group.sg_id
  from_port         = 8080
  protocol       = "tcp"
  to_port           = 8080
  source_security_group_id = module.backend_security_group.sg_id
}

#vpn accepting connections from backend 
# resource "aws_security_group_rule" "vpn_from_backend22" {
#   type = "ingress"
#   security_group_id = module.backend_security_group.sg_id
#   from_port         = 22
#   protocol       = "tcp"
#   to_port           = 22
#   source_security_group_id = module.vpn_sg.id

# }

resource "aws_security_group_rule" "backend_vpn" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  source_security_group_id = module.vpn_sg.sg_id
  security_group_id = module.backend_security_group.sg_id
}

resource "aws_security_group_rule" "web_lb_from_http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = module.web-lb.sg_id
}

resource "aws_security_group_rule" "web_lb_from_https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = module.web-lb.sg_id
}

resource "aws_security_group_rule" "frontend_from_vpn" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  source_security_group_id = module.vpn_sg.sg_id
  security_group_id = module.frontend_security_group.sg_id
}

resource "aws_security_group_rule" "frontend_from_web_lb" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  source_security_group_id = module.web-lb.sg_id
  security_group_id = module.frontend_security_group.sg_id
}

# resource "aws_security_group_rule" "app_lb_from_frontend" {
#   type              = "ingress"
#   from_port         = 80
#   to_port           = 80
#   protocol          = "tcp"
#   source_security_group_id = module.frontend_security_group.sg_id
#   security_group_id = module.app-lb.sg_id
# }









