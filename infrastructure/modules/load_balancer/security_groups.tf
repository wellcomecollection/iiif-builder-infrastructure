resource "aws_security_group" "web" {
  name        = "${var.name}_${var.environment}_web"
  description = "Web access for ALB"
  vpc_id      = var.vpc_id

  ingress {
    protocol  = "tcp"
    from_port = 80
    to_port   = 80

    cidr_blocks = var.lb_controlled_ingress_cidrs
  }

  ingress {
    protocol  = "tcp"
    from_port = 443
    to_port   = 443

    cidr_blocks = var.lb_controlled_ingress_cidrs
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    local.common_tags,
    map("Name", "${var.name}-${var.environment}-external-lb")
  )
}
