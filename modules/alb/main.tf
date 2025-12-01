resource "aws_lb" "this" {
  # stable short suffix so name doesn't change every plan/apply
  name               = "${var.environment}-alb-${substr(random_id.lb_suffix.hex, 0, 8)}"
  load_balancer_type = "application"
  subnets            = var.public_subnets
  security_groups    = [var.alb_sg_id]
}

resource "aws_lb_target_group" "this" {
  name     = "${var.environment}-tg-${substr(random_id.lb_suffix.hex, 0, 8)}"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/"
    unhealthy_threshold = 5
    healthy_threshold   = 2
    interval            = 60
    timeout             = 5
    matcher             = "200"
  }
}

resource "random_id" "lb_suffix" {
  byte_length = 4
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}
