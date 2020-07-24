# requests are forwarded via Wellcome's CloudFront so will come in with different hostname

# iiif.wellcomecollection.org/dash* -> dashboard
resource "aws_alb_listener_rule" "wc_dash" {
  listener_arn = data.terraform_remote_state.common.outputs.lb_listener_arn
  priority     = 1

  action {
    type             = "forward"
    target_group_arn = module.dashboard.service_target_group_arn
  }

  condition {
    field  = "host-header"
    values = ["iiif.wellcomecollection.org"]
  }

  condition {
    field  = "path-pattern"
    values = ["/dash*"]
  }
}

# iiif.wellcomecollection.org/* -> iiifbuilder
resource "aws_alb_listener_rule" "wc_iiifbuilder" {
  listener_arn = data.terraform_remote_state.common.outputs.lb_listener_arn
  priority     = 2

  action {
    type             = "forward"
    target_group_arn = module.iiif_builder.service_target_group_arn
  }

  condition {
    field  = "host-header"
    values = ["iiif.wellcomecollection.org"]
  }

  condition {
    field  = "path-pattern"
    values = ["/*"]
  }
}