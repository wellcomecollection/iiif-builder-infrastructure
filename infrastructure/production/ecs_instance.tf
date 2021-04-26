resource "aws_instance" "iiif_builder_ecs_host" {
  ami           = "ami-0c62045417a6d2199" # amazon linux 2
  instance_type = "m4.xlarge"

  subnet_id              = data.terraform_remote_state.platform_infra.outputs.digirati_vpc_private_subnets[0]
  vpc_security_group_ids = [data.terraform_remote_state.common.outputs.production_security_group_id,]

  iam_instance_profile = aws_iam_instance_profile.iiif_builder_host.id
  key_name             = "iiif-builder"
  source_dest_check    = "false"
  root_block_device {
    volume_type           = "gp2"
    volume_size           = "40"
    delete_on_termination = "true"
  }

  user_data = <<EOF
    #!/bin/bash
    echo ECS_CLUSTER=${aws_ecs_cluster.iiif_builder.name} >> /etc/ecs/ecs.config
    EOF  

  tags = merge(
    local.common_tags,
    map("Name", "iiif-builder-ecs-host")
  )
}

resource "aws_iam_instance_profile" "iiif_builder_host" {
  name = "iiif_builder_ecs_host_instance_profile"
  role = aws_iam_role.iiif_builder_host.name
}

data "aws_iam_policy_document" "assume_ec2_role" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = ["ecs.amazonaws.com", "ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "iiif_builder_host" {
  name               = "iiif_builder_ecs_host_instance_role"
  assume_role_policy = data.aws_iam_policy_document.assume_ec2_role.json
}

resource "aws_iam_role_policy_attachment" "host_ec2" {
  role       = aws_iam_role.iiif_builder_host.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}
