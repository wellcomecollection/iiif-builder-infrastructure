# Modules

A collection of reusable modules

* ecs/bastion - creates a single EC2 instance for allow SSH access to cluster.
* ecs - creates Fargate ECS service and task definition with logging configured. 
* load_balancer - ELB with http -> https redirect using certificate already in AWS.
* rds - created PostgreSQL RDS instance