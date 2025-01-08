resource "aws_ssm_parameter" "vpc_id" {
  name  = "/expense/dev/vpc_id"
  type  = "String"
  value = module.vpc.vpc_id
}

resource "aws_ssm_parameter" "public_subnet_ids" {
  name  = "/expense/dev/public_subnet_ids"
  type  = "StringList"
  value = join(",", module.vpc.subnet_ids)
}

resource "aws_ssm_parameter" "private_subnet_ids" {
  name  = "/expense/dev/private_subnet_ids"
  type  = "StringList"
  value = join(",", module.vpc.backend_subnet_id)
}

resource "aws_ssm_parameter" "database_subnet_ids" {
  name  = "/expense/dev/database_subnet_ids"
  type  = "StringList"
  value = join(",", module.vpc.database_subnet_id)
}

resource "aws_ssm_parameter" "db_subnet_group_name" {
  name  = "/expense/dev/db_subnet_group_name"
  type  = "String"
  value = module.vpc.db_subnet_group
}









