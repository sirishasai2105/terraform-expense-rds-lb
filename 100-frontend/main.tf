module "frontend" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  ami = data.aws_ami.ami_info.id

  name = local.name

  instance_type          = "t2.micro"
  vpc_security_group_ids = [local.frontend-sg-id]
  subnet_id              = local.public-subnet-id

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

resource "null_resource" "frontend" {
  # Changes to any instance of the cluster requires re-provisioning
  triggers = {
    instance_id = module.frontend.id
  }

  # Bootstrap script can run on any instance of the cluster
  # So we just choose the first in this case
  connection {
    host = module.frontend.public_ip
    type = "ssh"
    user = "ec2-user"
    password = "DevOps321"
  }

  # exports from local to remote server. if this block is not there then file in the local won't move to the remote and then cannot 
  provisioner "file" {
    source = "${var.frontend_tags.Component}.sh"
    destination = "/tmp/frontend.sh"
  }

  # executes the code in that remote file
  provisioner "remote-exec" {
    # Bootstrap script called with public_ip of each node in the cluster
    inline = [
        "chmod +x /tmp/frontend.sh",
        "sudo sh /tmp/frontend.sh ${var.frontend_tags.Component} ${var.environment}"
    ]
  }
}

resource "aws_ec2_instance_state" "frontend" {
  instance_id = module.frontend.id
  state       = "stopped"
  depends_on = [null_resource.frontend]
}

resource "aws_ami_from_instance" "frontend" {
  name               = local.name
  source_instance_id = module.frontend.id
  depends_on = [aws_ec2_instance_state.frontend]
}



resource "null_resource" "frontend_delete" {
  # Changes to any instance of the cluster requires re-provisioning
  triggers = {
    instance_id = module.frontend.id
  }

  # executes the code in that remote file
  provisioner "local-exec" {
    # Bootstrap script called with public_ip of each node in the cluster
    command =  "aws ec2 terminate-instances --instance-ids ${module.frontend.id}"
  }
  depends_on = [aws_ami_from_instance.frontend]
}

#creating the target group
resource "aws_lb_target_group" "frontend" {
  name     = local.name
  port     = 8080
  protocol = "HTTP"
  vpc_id   = local.vpc-id
  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2 
    interval = 5
    matcher = "200-299"
    path = "/"
    port = 8080
    protocol = "HTTP"
    timeout = 4

  }
}

#creating launch template
resource "aws_launch_template" "frontend" {
  name = local.name


  image_id = aws_ami_from_instance.frontend.id

  instance_initiated_shutdown_behavior = "terminate"
  update_default_version = true


  instance_type = "t2.micro"


  vpc_security_group_ids = [local.frontend-sg-id]

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = local.name
    }
  }
}

#creating autoscaling group

resource "aws_autoscaling_group" "frontend" {
  name                      = local.name
  max_size                  = 10
  min_size                  = 2
  health_check_grace_period = 60
  health_check_type         = "ELB"
  desired_capacity          = 2

  vpc_zone_identifier       = [local.public-subnet-id]
    launch_template {
    id      = aws_launch_template.frontend.id
    version = "$Latest"
    }

  tag {
    key                 = "Name"
    value               = local.name
    propagate_at_launch = true
  }
  target_group_arns = [aws_lb_target_group.frontend.arn]

  #if instance not healthy at 15 min autoscaling will delete the instance.
  timeouts {
    delete = "15m"
  }
   instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
    triggers = ["launch_template"]
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
  autoscaling_group_name  = aws_autoscaling_group.frontend.name
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 70.0
  }
}

#creating listener rule
resource "aws_lb_listener_rule" "host_based_routing" {
  listener_arn = local.listener-arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.frontend.arn}"
  }

  condition {
    host_header{
      values = ["expense-${var.environment}.${var.domain_name}"]

    }
  }
}