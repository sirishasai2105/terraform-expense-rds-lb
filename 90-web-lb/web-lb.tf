module "web-lb" {
  source = "terraform-aws-modules/alb/aws"
  internal = true
  enable_deletion_protection = false
  name    = local.name
  vpc_id  = local.vpc-id
  subnets = local.public-subnet-id
  #security_group_id = local.app-lb-sg-id
  security_groups = [local.web-lb-sg-id]
  create_security_group = false
  tags = {
    Name = "expense-dev-web-lb"
  }


}

resource "aws_lb_listener" "web-lb" {
  load_balancer_arn =  module.web-lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/html"
      message_body = "<h1>Hello, I am from web ALB</h1>"
      status_code  = "200"
    }
  }

  }

  resource "aws_lb_listener" "web-lb-https" {
  load_balancer_arn = module.web-lb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = local.certificate-manager
   default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/html"
      message_body = "<h1>Hello, I am from web ALB</h1>"
      status_code  = "200"
    }
}
  }



module "records" {
  source  = "terraform-aws-modules/route53/aws//modules/records"

  zone_name = var.zone_name #daws81s.online
  records = [
    {
      name    = "expense-${var.environment}" # *.app-dev
      type    = "A"
      alias   = {
        name    = module.web-lb.dns_name
        zone_id = module.web-lb.zone_id # This belongs ALB internal hosted zone, not ours
      }
      allow_overwrite = true
    }
  ]
}