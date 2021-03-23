# requests are forwarded via Wellcome's CloudFront so will come in with different hostname
# this is only required if 'All' or 'Host' is whitelisted, which is the case for dash + dds

# iiif-stage.wellcomecollection.org/dash* -> dashboard-stage
resource "aws_alb_listener_rule" "wc_dash_stage" {
  listener_arn = data.terraform_remote_state.common.outputs.lb_listener_arn
  priority     = 3

  action {
    type             = "forward"
    target_group_arn = module.dashboard.service_target_group_arn
  }

  condition {
    host_header {
      values = ["iiif-stage.wellcomecollection.org"]
    }
  }

  condition {
    path_pattern {
      values = ["/dash*"]
    }
  }
}

# iiif-stage.wellcomecollection.org/* -> iiifbuilder-stage
resource "aws_alb_listener_rule" "wc_iiifbuilder_stage" {
  listener_arn = data.terraform_remote_state.common.outputs.lb_listener_arn
  priority     = 250

  action {
    type             = "forward"
    target_group_arn = module.iiif_builder.service_target_group_arn
  }

  condition {
    host_header {
      values = ["iiif-stage.wellcomecollection.org"]
    }
  }

  condition {
    path_pattern {
      values = ["/*"]
    }
  }
}

# iiif-stage.wellcomecollection.org/text* -> iiifbuilder-text-stage
resource "aws_alb_listener_rule" "wc_text_stage" {
  listener_arn = data.terraform_remote_state.common.outputs.lb_listener_arn
  priority     = 32

  action {
    type             = "forward"
    target_group_arn = module.iiif_builder_text.service_target_group_arn
  }

  condition {
    host_header {
      values = ["iiif-stage.wellcomecollection.org"]
    }
  }

  condition {
    path_pattern {
      values = ["/text*"]
    }
  }
}

# iiif-stage.wellcomecollection.org/search* -> iiifbuilder-text-stage
resource "aws_alb_listener_rule" "wc_search_stage" {
  listener_arn = data.terraform_remote_state.common.outputs.lb_listener_arn
  priority     = 33

  action {
    type             = "forward"
    target_group_arn = module.iiif_builder_text.service_target_group_arn
  }

  condition {
    host_header {
      values = ["iiif-stage.wellcomecollection.org"]
    }
  }

  condition {
    path_pattern {
      values = ["/search*"]
    }
  }
}

# iiif-test.wellcomecollection.org/dash* -> dashboard-stgprd
resource "aws_alb_listener_rule" "wc_dash_stageprd" {
  listener_arn = data.terraform_remote_state.common.outputs.lb_listener_arn
  priority     = 5

  action {
    type             = "forward"
    target_group_arn = module.dashboard_stageprod.service_target_group_arn
  }

  condition {
    host_header {
      values = ["iiif-test.wellcomecollection.org"]
    }
  }

  condition {
    path_pattern {
      values = ["/dash*"]
    }
  }
}

# iiif-test.wellcomecollection.org/* -> iiifbuilder-stgprd
resource "aws_alb_listener_rule" "wc_iiifbuilder_stageprd" {
  listener_arn = data.terraform_remote_state.common.outputs.lb_listener_arn
  priority     = 240

  action {
    type             = "forward"
    target_group_arn = module.iiif_builder_stageprod.service_target_group_arn
  }

  condition {
    host_header {
      values = ["iiif-test.wellcomecollection.org"]
    }
  }

  condition {
    path_pattern {
      values = ["/*"]
    }
  }
}

# iiif-test.wellcomecollection.org/text* -> iiifbuilder-text-test
resource "aws_alb_listener_rule" "wc_text_stageprd" {
  listener_arn = data.terraform_remote_state.common.outputs.lb_listener_arn
  priority     = 36

  action {
    type             = "forward"
    target_group_arn = module.iiif_builder_text_stageprod.service_target_group_arn
  }

  condition {
    host_header {
      values = ["iiif-test.wellcomecollection.org"]
    }
  }

  condition {
    path_pattern {
      values = ["/text*"]
    }
  }
}

# iiif-test.wellcomecollection.org/search* -> iiifbuilder-text-test
resource "aws_alb_listener_rule" "wc_search_stageprd" {
  listener_arn = data.terraform_remote_state.common.outputs.lb_listener_arn
  priority     = 37

  action {
    type             = "forward"
    target_group_arn = module.iiif_builder_text_stageprod.service_target_group_arn
  }

  condition {
    host_header {
      values = ["iiif-test.wellcomecollection.org"]
    }
  }

  condition {
    path_pattern {
      values = ["/search*"]
    }
  }
}