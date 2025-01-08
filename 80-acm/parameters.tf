resource "aws_ssm_parameter" "acm" {
  name  = "/${var.project_name}/${var.environment}/acm"
  type  = "String"
  value = aws_acm_certificate.expense.arn
  # lifecycle {
  #   prevent_destroy = true  # Prevents accidental deletion
  # }

}