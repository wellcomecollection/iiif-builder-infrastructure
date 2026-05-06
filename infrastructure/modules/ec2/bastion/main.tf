# Bastion module
resource "aws_security_group" "bastion" {
  name        = "${var.name}-bastion"
  description = "SSH access"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.ip_whitelist
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${var.name}-ssh-access" })
  )
}

data "aws_iam_policy_document" "assume_role_policy_ec2" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "bastion" {
  name               = "${var.name}-bastion"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy_ec2.json
}

data "aws_iam_policy_document" "bastion_abilities" {
  statement {
    sid = "allowLoggingToCloudWatch"

    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = ["*"]
  }
}

resource "aws_iam_policy" "bastion_abilities" {
  name        = "${var.name}-bastion-abilities"
  description = "Bastion userdata abilities"
  policy      = data.aws_iam_policy_document.bastion_abilities.json
}

resource "aws_iam_role_policy_attachment" "bastion_abilities" {
  role       = aws_iam_role.bastion.name
  policy_arn = aws_iam_policy.bastion_abilities.arn
}

data "aws_iam_policy" "ssm_managed" {
  name = "AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "bastion_ssm" {
  role       = aws_iam_role.bastion.name
  policy_arn = data.aws_iam_policy.ssm_managed.arn
}

data "aws_iam_policy_document" "scheduler_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["scheduler.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "bastion_refresh_scheduler" {
  name               = "${var.name}-bastion-refresh-scheduler"
  assume_role_policy = data.aws_iam_policy_document.scheduler_assume_role.json
}

resource "aws_iam_role_policy" "bastion_refresh_scheduler" {
  role = aws_iam_role.bastion_refresh_scheduler.name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = "autoscaling:StartInstanceRefresh"
      Resource = aws_autoscaling_group.bastion.arn
    }]
  })
}

resource "aws_scheduler_schedule" "bastion_refresh" {
  name       = "${var.name}-bastion-refresh"
  group_name = "default"

  flexible_time_window { mode = "OFF" }

  schedule_expression = var.refresh_schedule

  target {
    arn      = "arn:aws:scheduler:::aws-sdk:autoscaling:startInstanceRefresh"
    role_arn = aws_iam_role.bastion_refresh_scheduler.arn
    input = jsonencode({
      AutoScalingGroupName = aws_autoscaling_group.bastion.name
    })
  }
}

resource "aws_iam_instance_profile" "bastion" {
  name = "${var.name}-bastion"
  role = aws_iam_role.bastion.name
}

resource "aws_launch_template" "bastion" {
  name_prefix   = "${var.name}-bastion"
  image_id      = var.ami
  instance_type = var.instance_type
  key_name      = var.key_name

  iam_instance_profile {
    name = aws_iam_instance_profile.bastion.name
  }

  network_interfaces {
    associate_public_ip_address = true
    security_groups = concat(
      var.service_security_group_ids,
      [aws_security_group.bastion.id],
    )
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "bastion" {
  name = "${var.name}-bastion"

  launch_template {
    id      = aws_launch_template.bastion.id
    version = "$Latest"
  }

  max_size            = "1"
  min_size            = "1"
  vpc_zone_identifier = var.subnets

  default_cooldown = 0

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 0
    }
  }

  lifecycle {
    create_before_destroy = true
  }

  tag {
    key                 = "Name"
    value               = "${var.name}-bastion"
    propagate_at_launch = true
  }

  tag {
    key                 = "Project"
    value               = var.name
    propagate_at_launch = true
  }
}
