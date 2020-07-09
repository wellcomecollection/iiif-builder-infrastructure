# Modules

A collection of reusable modules

* ec2/bastion - creates a single EC2 instance for allow SSH access to cluster.
* ecs/private - creates Fargate ECS service and task definition with logging configured.
* ecs/web - creates Fargate ECS service and task definition with logging configured. Also creates alb targetgroup, rules and route53 A record.
* load_balancer - ELB with http -> https redirect using certificate already in AWS.
* rds - created PostgreSQL RDS instance