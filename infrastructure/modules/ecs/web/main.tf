# Logging container using fluentbit
module "log_router_container" {
  source    = "git::https://github.com/wellcomecollection/terraform-aws-ecs-service.git//modules/firelens?ref=v2.6.3"
  namespace = local.full_name
}

module "log_router_permissions" {
  source    = "git::https://github.com/wellcomecollection/terraform-aws-ecs-service.git//modules/secrets?ref=v2.6.3"
  secrets   = module.log_router_container.shared_secrets_logging
  role_name = module.task_definition.task_execution_role_name
}

# Create container definitions
module "application_container_definition" {
  source = "git::https://github.com/wellcomecollection/terraform-aws-ecs-service.git//modules/container_definition?ref=v2.6.3"
  name   = local.full_name

  image         = var.docker_image
  port_mappings = var.port_mappings

  secrets     = var.secret_env_vars
  environment = var.env_vars

  log_configuration = module.log_router_container.container_log_configuration

  tags = local.common_tags
}

# Create task definition
module "task_definition" {
  source = "git::https://github.com/wellcomecollection/terraform-aws-ecs-service.git//modules/task_definition?ref=v2.6.3"

  cpu    = var.cpu
  memory = var.memory

  container_definitions = [
    module.log_router_container.container_definition,
    module.application_container_definition.container_definition
  ]

  launch_types = ["FARGATE"]
  task_name    = local.full_name
}

# secrets
module "app_container_secrets_permissions" {
  source    = "git::github.com/wellcomecollection/terraform-aws-ecs-service.git//modules/secrets?ref=v2.6.3"
  secrets   = var.secret_env_vars
  role_name = module.task_definition.task_execution_role_name
}

# Create service
module "service" {
  source = "git::https://github.com/wellcomecollection/terraform-aws-ecs-service.git//modules/service?ref=v2.6.3"

  cluster_arn  = var.ecs_cluster_arn
  service_name = local.full_name

  task_definition_arn = module.task_definition.arn

  service_discovery_namespace_id = var.service_discovery_namespace_id

  subnets            = var.service_subnets
  security_group_ids = var.service_security_group_ids

  target_group_arn = aws_alb_target_group.service.arn
  container_port   = var.container_port
  container_name   = local.full_name
}

resource "aws_alb_target_group" "service" {
  # We use snake case in a lot of places, but ALB Target Group names can
  # only contain alphanumerics and hyphens.
  name        = replace(local.full_name, "_", "-")
  target_type = "ip"
  protocol    = "HTTP"

  deregistration_delay = 10
  port                 = var.container_port
  vpc_id               = var.vpc_id

  health_check {
    path                = var.healthcheck_path
    port                = var.container_port
    protocol            = "HTTP"
    matcher             = 200
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_alb_listener_rule" "https" {
  count        = length(var.path_patterns)
  listener_arn = var.lb_listener_arn
  priority     = var.listener_priority + count.index

  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.service.arn
  }

  condition {
    host_header {
      values = [var.hostname == "" ? var.domain : "${var.hostname}.${var.domain}"]
    }
  }

  condition {
    path_pattern {
      values = [element(var.path_patterns, count.index)]
    }
  }
}

resource "aws_route53_record" "service" {
  count   = var.create_dns ? 1 : 0
  zone_id = var.zone_id
  name    = "${var.hostname}.${var.domain}"
  type    = "A"

  alias {
    name                   = var.lb_fqdn
    zone_id                = var.lb_zone_id
    evaluate_target_health = false
  }
}