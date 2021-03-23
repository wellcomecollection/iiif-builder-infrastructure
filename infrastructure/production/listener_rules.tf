# requests are forwarded via Wellcome's CloudFront so will come in with different hostname
# this is only required if 'All' or 'Host' is whitelisted, which is the case for dash + dds

# iiif.wellcomecollection.org/dash* -> dashboard
resource "aws_alb_listener_rule" "wc_dash" {
  listener_arn = data.terraform_remote_state.common.outputs.lb_listener_arn
  priority     = 1

  action {
    type             = "forward"
    target_group_arn = module.dashboard.service_target_group_arn
  }

  condition {
    host_header {
      values = ["iiif.wellcomecollection.org"]
    }
  }

  condition {
    path_pattern {
      values = ["/dash*"]
    }
  }
}

# iiif.wellcomecollection.org/* -> iiifbuilder
resource "aws_alb_listener_rule" "wc_iiifbuilder" {
  listener_arn = data.terraform_remote_state.common.outputs.lb_listener_arn
  priority     = 200

  action {
    type             = "forward"
    target_group_arn = module.iiif_builder.service_target_group_arn
  }

  condition {
    host_header {
      values = ["iiif.wellcomecollection.org"]
    }
  }

  condition {
    path_pattern {
      values = ["/*"]
    }
  }
}

# iiif.wellcomecollection.org/text* -> iiifbuilder
resource "aws_alb_listener_rule" "wc_text" {
  listener_arn = data.terraform_remote_state.common.outputs.lb_listener_arn
  priority     = 42

  action {
    type             = "forward"
    target_group_arn = module.iiif_builder_text.service_target_group_arn
  }

  condition {
    host_header {
      values = ["iiif.wellcomecollection.org"]
    }
  }

  condition {
    path_pattern {
      values = ["/text*"]
    }
  }
}

# iiif.wellcomecollection.org/search* -> iiifbuilder
resource "aws_alb_listener_rule" "wc_search" {
  listener_arn = data.terraform_remote_state.common.outputs.lb_listener_arn
  priority     = 43

  action {
    type             = "forward"
    target_group_arn = module.iiif_builder_text.service_target_group_arn
  }

  condition {
    host_header {
      values = ["iiif.wellcomecollection.org"]
    }
  }

  condition {
    path_pattern {
      values = ["/search*"]
    }
  }
}