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
    tomap({"Name" = "${var.name}-ssh-access"})
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

resource "aws_iam_instance_profile" "bastion" {
  name = "${var.name}-bastion"
  role = aws_iam_role.bastion.name
}

resource "aws_launch_configuration" "bastion" {
  name_prefix          = "${var.name}-bastion"
  image_id             = var.ami
  instance_type        = var.instance_type
  iam_instance_profile = aws_iam_instance_profile.bastion.name
  key_name             = var.key_name

  security_groups = concat(
    var.service_security_group_ids,
    [aws_security_group.bastion.id],
  )

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "bastion" {
  name                 = "${var.name}-bastion"
  launch_configuration = aws_launch_configuration.bastion.name

  max_size            = "1"
  min_size            = "1"
  vpc_zone_identifier = var.subnets

  default_cooldown = 0

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
