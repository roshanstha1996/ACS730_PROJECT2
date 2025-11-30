data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_launch_template" "this" {
  name_prefix   = "lt-${var.environment}-"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type

  # THIS IS THE MISSING PIECE FOR AWS ACADEMY
  iam_instance_profile {
    name = "LabInstanceProfile"
  }

  user_data = base64encode(templatefile("${path.module}/user-data.sh.tpl", {
    bucket_name = var.web_bucket
    environment = var.environment
  }))

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.environment}-web-server-${substr(uuid(), 0, 8)}"
    }
  }

  vpc_security_group_ids = [var.ec2_sg_id]
}
