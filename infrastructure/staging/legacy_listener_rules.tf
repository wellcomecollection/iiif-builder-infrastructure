# DNS / ALB rules for dlcs.io (will eventually be deleted)

# pdf-stage
resource "aws_alb_listener_rule" "pdf_stage_dlcs_io" {
  listener_arn = data.terraform_remote_state.common.outputs.lb_listener_arn
  priority     = 4

  action {
    type             = "forward"
    target_group_arn = module.pdf_generator.service_target_group_arn
  }

  condition {
    host_header {
      values = ["pdf-stage.${local.domain}"]
    }
  }

  condition {
    path_pattern {
      values = ["/*"]
    }
  }
}

resource "aws_route53_record" "pdf_stage_dlcs_io" {
  zone_id = data.aws_route53_zone.external.id
  name    = "pdf-stage.${local.domain}"
  type    = "A"

  alias {
    name                   = data.terraform_remote_state.common.outputs.lb_fqdn
    zone_id                = data.terraform_remote_state.common.outputs.lb_zone_id
    evaluate_target_health = false
  }
}

# dashboard-stage
resource "aws_alb_listener_rule" "dashboard_stage_dlcs_io" {
  listener_arn = data.terraform_remote_state.common.outputs.lb_listener_arn
  priority     = 30

  action {
    type             = "forward"
    target_group_arn = module.dashboard.service_target_group_arn
  }

  condition {
    host_header {
      values = ["dds-stage.${local.domain}"]
    }
  }

  condition {
    path_pattern {
      values = ["/*"]
    }
  }
}

resource "aws_route53_record" "dashboard_stage_dlcs_io" {
  zone_id = data.aws_route53_zone.external.id
  name    = "dds-stage.${local.domain}"
  type    = "A"

  alias {
    name                   = data.terraform_remote_state.common.outputs.lb_fqdn
    zone_id                = data.terraform_remote_state.common.outputs.lb_zone_id
    evaluate_target_health = false
  }
}

# dashboard-test
resource "aws_alb_listener_rule" "dashboard_stageprod_dlcs_io" {
  listener_arn = data.terraform_remote_state.common.outputs.lb_listener_arn
  priority     = 31

  action {
    type             = "forward"
    target_group_arn = module.dashboard_stageprod.service_target_group_arn
  }

  condition {
    host_header {
      values = ["dds-test.${local.domain}"]
    }
  }

  condition {
    path_pattern {
      values = ["/*"]
    }
  }
}

resource "aws_route53_record" "dashboard_stageprod_dlcs_io" {
  zone_id = data.aws_route53_zone.external.id
  name    = "dds-test.${local.domain}"
  type    = "A"

  alias {
    name                   = data.terraform_remote_state.common.outputs.lb_fqdn
    zone_id                = data.terraform_remote_state.common.outputs.lb_zone_id
    evaluate_target_health = false
  }
}

# iiif-builder-stage
resource "aws_alb_listener_rule" "iiif_builder_stage_dlcs_io" {
  listener_arn = data.terraform_remote_state.common.outputs.lb_listener_arn
  priority     = 32

  action {
    type             = "forward"
    target_group_arn = module.iiif_builder.service_target_group_arn
  }

  condition {
    host_header {
      values = ["iiif-stage.${local.domain}"]
    }
  }

  condition {
    path_pattern {
      values = ["/*"]
    }
  }
}

resource "aws_route53_record" "iiif_builder_stage_dlcs_io" {
  zone_id = data.aws_route53_zone.external.id
  name    = "iiif-stage.${local.domain}"
  type    = "A"

  alias {
    name                   = data.terraform_remote_state.common.outputs.lb_fqdn
    zone_id                = data.terraform_remote_state.common.outputs.lb_zone_id
    evaluate_target_health = false
  }
}

# iiif-builder-test
resource "aws_alb_listener_rule" "iiif_builder_stageprod_dlcs_io" {
  listener_arn = data.terraform_remote_state.common.outputs.lb_listener_arn
  priority     = 33

  action {
    type             = "forward"
    target_group_arn = module.iiif_builder_stageprod.service_target_group_arn
  }

  condition {
    host_header {
      values = ["iiif-test.${local.domain}"]
    }
  }

  condition {
    path_pattern {
      values = ["/*"]
    }
  }
}

resource "aws_route53_record" "iiif_builder_stageprod_dlcs_io" {
  zone_id = data.aws_route53_zone.external.id
  name    = "iiif-test.${local.domain}"
  type    = "A"

  alias {
    name                   = data.terraform_remote_state.common.outputs.lb_fqdn
    zone_id                = data.terraform_remote_state.common.outputs.lb_zone_id
    evaluate_target_health = false
  }
}