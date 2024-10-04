resource "aws_key_pair" "openvpn" {
  key_name   = "openvpn"
  #public_key = file("/c/Users/BABLU/openvpn.pub")
  public_key = file("openvpn.pub")
  #public_key = file("C:\\Users\\BABLU\\openvpn.pub")
  }


module "vpn_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"

  name = local.name
  ami = data.aws_ami.ami_info.id

  instance_type          = "t2.micro"
  key_name               = aws_key_pair.openvpn.key_name
  monitoring             = true
  vpc_security_group_ids = [data.aws_ssm_parameter.vpn_sg_id.value]
  subnet_id              = local.public-subnet-id

  tags = {
    Terraform   = "true"
    Environment = "dev"

  }
}