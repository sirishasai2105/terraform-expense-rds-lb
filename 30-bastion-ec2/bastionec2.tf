module "bastion_ec2" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  ami = data.aws_ami.ami_info.id

  name = local.name

  instance_type          = "t2.micro"
  vpc_security_group_ids = [local.bastion-id]
  subnet_id              = local.public-subnet-id

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}