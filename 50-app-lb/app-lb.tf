module "app-lb" {
  source = "terraform-aws-modules/alb/aws"
  internal = true
  enable_deletion_protection = false
  name    = local.name
  vpc_id  = data.aws_ssm_parameter.vpc_id.id
  subnets = local.private-subnet-id
  #security_group_id = local.app-lb-sg-id
  security_groups = [local.app-lb-sg-id]
  create_security_group = false
  tags = {
    Name = "expense-dev-app-lb"
  }


}

resource "aws_lb_listener" "app-lb" {
  load_balancer_arn =  module.app-lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/html"
      message_body = "<h1>Hello, I am from Application ALB</h1>"
      status_code  = "200"
    }
  }

  }


# module "records" {
#   source  = "terraform-aws-modules/route53/aws//modules/records"
#   version = "~> 3.0"

#   zone_name = var.zone_name
#   records = [
#     {
#       name    = "*.app-dev"
#       type    = "A"
#       ttl     = 1
#       records = [
#          module.app-lb.dns_name,
#       ]
#     },
#   ]

# }

module "records" {
  source  = "terraform-aws-modules/route53/aws//modules/records"

  zone_name = var.zone_name #daws81s.online
  records = [
    {
      name    = "*.app-${var.environment}" # *.app-dev
      type    = "A"
      alias   = {
        name    = module.app-lb.dns_name
        zone_id = module.app-lb.zone_id # This belongs ALB internal hosted zone, not ours
      }
      allow_overwrite = true
    }
  ]
}