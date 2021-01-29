# requests are forwarded via Wellcome's CloudFront so will come in with different hostname

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
  priority     = 21

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
  priority     = 20

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