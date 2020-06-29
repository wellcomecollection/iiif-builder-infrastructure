data "aws_acm_certificate" "certificate" {
  domain      = var.certificate_domain
  statuses    = ["ISSUED"]
  most_recent = true
}

resource "aws_alb" "lb" {
  name = replace(var.name, "_", "-")

  subnets = var.public_subnets

  security_groups = concat(
    var.service_lb_security_group_ids,
    [aws_security_group.web.id],
  )

  tags = local.common_tags
}

resource "aws_alb_target_group" "default" {
  name                 = var.name
  port                 = 80
  protocol             = "HTTP"
  vpc_id               = var.vpc_id
  deregistration_delay = 30

  health_check {
    path                = "/"
    timeout             = 30
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 60
    matcher             = "200,404"
  }
}

# redirect http -> https
resource "aws_lb_listener" "http_redirect" {
  load_balancer_arn = aws_alb.lb.id
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_302"
    }
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_alb.lb.id
  port              = 443
  protocol          = "HTTPS"

  ssl_policy      = "ELBSecurityPolicy-2016-08"
  certificate_arn = data.aws_acm_certificate.certificate.arn

  default_action {
    target_group_arn = aws_alb_target_group.default.id
    type             = "forward"
  }
}