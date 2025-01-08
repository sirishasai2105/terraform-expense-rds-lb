module "db" {
  source = "terraform-aws-modules/rds/aws"

  #name of the rds
  identifier = local.name

  engine            = "mysql"
  engine_version    = "8.0"
  instance_class    = "db.t3.micro"
  allocated_storage = 5

  #db credential information
  db_name  = "transactions"
  username = "root"
  manage_master_user_password = false
  password = "ExpenseApp1"
  port     = "3306"


  #security group that rds has to attach i.e mysql sg
  vpc_security_group_ids = [local.mysql_sg_id]


  # tags for the project
  tags = {
    project = "expense"
    environment = "dev"
    component = "rds"
  }

  # DB subnet group
  db_subnet_group_name = local.db_subnet_group_id

  #subnet id
  subnet_ids             = [local.db_subnet_group_id]

  # DB parameter group
  family = "mysql8.0"

  # DB option group
  major_engine_version = "8.0"

# if backup not required then true else false
skip_final_snapshot = true

  parameters = [
    {
      name  = "character_set_client"
      value = "utf8mb4"
    },
    {
      name  = "character_set_server"
      value = "utf8mb4"
    }
  ]

  options = [
    {
      option_name = "MARIADB_AUDIT_PLUGIN"

      option_settings = [
        {
          name  = "SERVER_AUDIT_EVENTS"
          value = "CONNECT"
        },
        {
          name  = "SERVER_AUDIT_FILE_ROTATIONS"
          value = "37"
        },
      ]
    },
  ]
}


module "records" {
  source    = "terraform-aws-modules/route53/aws//modules/records"

  zone_name = var.zone_name

  records = [
    {
      name    = "mysql-${var.environment}"
      type    = "CNAME"  # Use 'A' if pointing to an IP, 'CNAME' if pointing to another domain
      ttl     = 1
      records = [
        module.db.db_instance_address,
      ]
      allow_overwrite = true
    }
  ]
}
