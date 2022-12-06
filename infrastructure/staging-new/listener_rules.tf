# requests are forwarded via Wellcome's CloudFront so will come in with different hostname
# this is only required if 'All' or 'Host' is whitelisted, which is the case for dash + dds

# Going to leave priorities as-is so hopefully they interleave with existing rules

# iiif-stage-new.wellcomecollection.org/dash* -> dashboard-stage-new
resource "aws_alb_listener_rule" "wc_dash_stage_new" {
  listener_arn = data.terraform_remote_state.common.outputs.lb_listener_arn
  priority     = 3

  action {
    type             = "forward"
    target_group_arn = module.dashboard.service_target_group_arn
  }

  condition {
    host_header {
      values = ["iiif-stage-new.wellcomecollection.org"]
    }
  }

  condition {
    path_pattern {
      values = ["/dash*"]
    }
  }
}

# iiif-stage-new.wellcomecollection.org/* -> iiifbuilder-stage-new
resource "aws_alb_listener_rule" "wc_iiifbuilder_stage_new" {
  listener_arn = data.terraform_remote_state.common.outputs.lb_listener_arn
  priority     = 250

  action {
    type             = "forward"
    target_group_arn = module.iiif_builder.service_target_group_arn
  }

  condition {
    host_header {
      values = ["iiif-stage-new.wellcomecollection.org"]
    }
  }

  condition {
    path_pattern {
      values = ["/*"]
    }
  }
}

# iiif-stage-new.wellcomecollection.org/text* -> iiifbuilder-text-stage-new
resource "aws_alb_listener_rule" "wc_text_stage_new" {
  listener_arn = data.terraform_remote_state.common.outputs.lb_listener_arn
  priority     = 32

  action {
    type             = "forward"
    target_group_arn = module.iiif_builder_text.service_target_group_arn
  }

  condition {
    host_header {
      values = ["iiif-stage-new.wellcomecollection.org"]
    }
  }

  condition {
    path_pattern {
      values = ["/text*"]
    }
  }
}

# iiif-stage-new.wellcomecollection.org/search* -> iiifbuilder-text-stage-new
resource "aws_alb_listener_rule" "wc_search_stage_new" {
  listener_arn = data.terraform_remote_state.common.outputs.lb_listener_arn
  priority     = 33

  action {
    type             = "forward"
    target_group_arn = module.iiif_builder_text.service_target_group_arn
  }

  condition {
    host_header {
      values = ["iiif-stage-new.wellcomecollection.org"]
    }
  }

  condition {
    path_pattern {
      values = ["/search*"]
    }
  }
}
