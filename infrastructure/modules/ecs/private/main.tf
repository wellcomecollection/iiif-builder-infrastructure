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
  healthcheck   = var.healthcheck

  secrets     = var.secret_env_vars
  environment = var.env_vars

  memory_reservation = var.memory_reservation

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

  launch_types = var.launch_types
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
  source = "git::https://github.com/wellcomecollection/terraform-aws-ecs-service.git//modules/service?ref=v3.3.0"

  cluster_arn  = var.ecs_cluster_arn
  service_name = local.full_name

  task_definition_arn = module.task_definition.arn

  service_discovery_namespace_id = var.service_discovery_namespace_id

  subnets            = var.service_subnets
  security_group_ids = var.service_security_group_ids

  container_name = local.full_name

  desired_task_count = var.desired_count

  launch_type = var.launch_types[0]
}