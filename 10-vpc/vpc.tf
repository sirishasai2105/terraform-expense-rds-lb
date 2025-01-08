module "vpc" {
    #source = "git::https://github.com/sirishasai2105/terraform-aws-vpc.git?ref=main"
    source = "../../terraform-aws-vpc"
    #source = "./c/devops/daws-81s/repos/terraform-aws-vpc"
    project_name = "expense"
    environment = "dev"
    public_cidr_blocks = var.public_cidr_blocks
    private_subnet_cidrs = var.private_subnet_cidrs_block
    database_subnet_cidrs = var.database_subnet_cidr_block
    is_peering_required = var.is_peering_required
}


# ../../sopmthng
# /devops/daws-81s/repos/

# source = "git::<httos_url_paste_here>?ref=main"