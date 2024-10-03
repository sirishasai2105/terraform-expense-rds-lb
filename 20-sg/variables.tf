variable "project_name" {
    default = "expense"
}

variable "environment" {
    default = "dev" 
}

variable "mysql_sg_tags" {
    default = "mysql_sg"
}

variable "backend_sg_tags" {
default = "backend_sg"
}

variable "database_sg_tags" {
    default = "frontend_sg"
}

variable "bastion_sg_tags" {
    default = "bastion_sg"
}

variable "ansible_sg_tags" {
    default = "ansible_sg"
}

variable "app_lb_tags" {
    default = "app-lb"
}





