resource "aws_security_group" "ec2_sg" {
  name        = "${var.environment}-ec2-sg"
  vpc_id      = var.vpc_id
  description = "EC2 access from Bastion and ALB"

  tags = {
    Name        = "${var.environment}-ec2-sg"
    Environment = var.environment
  }

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [var.bastion_sg_id]
  }
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "alb_sg" {
  name        = "${var.environment}-alb-sg"
  vpc_id      = var.vpc_id
  description = "Allow HTTP inbound"

  tags = {
    Name        = "${var.environment}-alb-sg"
    Environment = var.environment
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


# REMOVED OUTPUTS
