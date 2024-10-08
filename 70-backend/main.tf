module "backend" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  ami = data.aws_ami.ami_info.id

  name = local.name

  instance_type          = "t2.micro"
  vpc_security_group_ids = [local.backend-sg-id]
  subnet_id              = local.private-subnet-id

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

resource "null_resource" "backend" {
  # Changes to any instance of the cluster requires re-provisioning
  triggers = {
    instance_id = module.backend.id
  }

  # Bootstrap script can run on any instance of the cluster
  # So we just choose the first in this case
  connection {
    host = module.backend.private_ip
    type = "ssh"
    user = "ec2-user"
    password = "DevOps321"
  }

  # exports from local to remote server. if this block is not there then file in the local won't move to the remote and then cannot 
  provisioner "file" {
    source = "${var.backend_tags.Component}.sh"
    destination = "/tmp/backend.sh"
  }

  # executes the code in that remote file
  provisioner "remote-exec" {
    # Bootstrap script called with private_ip of each node in the cluster
    inline = [
        "chmod +x /tmp/backend.sh",
        "sudo sh /tmp/backend.sh ${var.backend_tags.Component} ${var.environment}"
    ]
  }
}

resource "aws_ec2_instance_state" "backend" {
  instance_id = module.backend.id
  state       = "stopped"
  depends_on = [null_resource.backend]
}

resource "aws_ami_from_instance" "backend" {
  name               = local.name
  source_instance_id = module.backend.id
  depends_on = [aws_ec2_instance_state.backend]
}



resource "null_resource" "backend_delete" {
  # Changes to any instance of the cluster requires re-provisioning
  triggers = {
    instance_id = module.backend.id
  }

  # executes the code in that remote file
  provisioner "local-exec" {
    # Bootstrap script called with private_ip of each node in the cluster
    command =  "aws ec2 terminate-instances --instance-ids ${module.backend.id}"
  }
  depends_on = [aws_ami_from_instance.backend]
}

#creating the target group
resource "aws_lb_target_group" "backend" {
  name     = local.name
  port     = 8080
  protocol = "HTTP"
  vpc_id   = local.vpc-id
  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2 
    interval = 5
    matcher = "200-299"
    path = "/health"
    port = 8080
    protocol = "HTTP"
    timeout = 4

  }
}

#creating launch template
resource "aws_launch_template" "backend" {
  name = local.name


  image_id = aws_ami_from_instance.backend.id

  instance_initiated_shutdown_behavior = "terminate"
  update_default_version = true


  instance_type = "t2.micro"


  vpc_security_group_ids = [local.backend-sg-id]

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = local.name
    }
  }
}

#creating autoscaling group

resource "aws_autoscaling_group" "backend" {
  name                      = local.name
  max_size                  = 10
  min_size                  = 2
  health_check_grace_period = 60
  health_check_type         = "ELB"
  desired_capacity          = 2

  vpc_zone_identifier       = [local.private-subnet-id]
    launch_template {
    id      = aws_launch_template.backend.id
    version = "$Latest"
    }

  tag {
    key                 = "Name"
    value               = local.name
    propagate_at_launch = true
  }

  #if instance not healthy at 15 min autoscaling will delete the instance.
  timeouts {
    delete = "15m"
  }

  tag {
    key                 = "Project"
    value               = "Expense"
    propagate_at_launch = false
  }
}


resource "aws_autoscaling_policy" "example" {
  name = local.name
  policy_type            = "TargetTrackingScaling"
  autoscaling_group_name  = aws_autoscaling_group.backend.name
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 70.0
  }
}