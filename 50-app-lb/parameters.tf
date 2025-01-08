resource "aws_ssm_parameter" "listener_arn" {
  name  = "/${var.project_name}/${var.environment}/app-lb-listerner-arn"
  type  = "String"
  value = aws_lb_listener.app-lb.arn
  # lifecycle {
  #   prevent_destroy = true  # Prevents accidental deletion
  # }

}