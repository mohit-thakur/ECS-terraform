provider "aws" {
  access_key = ""
  secret_key = ""
  region     = "us-east-2"
}

data "aws_ami" "ecs_ami" {
  most_recent = true

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["amzn-ami-${var.ami_version}-amazon-ecs-optimized"]
  }
}

data "template_file" "user_data" {
  template = "${file("scripts/start-ecs.sh")}"

  vars {
    cluster_name                = "${aws_ecs_cluster.cluster.name}"
    docker_storage_size         = "${var.docker_storage_size}"
    dockerhub_token             = "${var.dockerhub_token}"
    dockerhub_email             = "${var.dockerhub_email}"
  }
}

resource "aws_ecs_cluster" "cluster" {
  name = "${var.ecs_cluster_name}"
}

resource "aws_security_group" "ecs" {
  name        = "ecs-sg-${var.ecs_cluster_name}"
  description = "Container Instance Allowed Ports"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["${var.allowed_cidr_blocks}"]
  }

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "udp"
    cidr_blocks = ["${var.allowed_cidr_blocks}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "ecs-sg-${var.ecs_cluster_name}"
  }
}

resource "aws_launch_configuration" "ecs" {
  name_prefix                 = "ecs-${var.ecs_cluster_name}-"
  depends_on = ["aws_iam_instance_profile.ecs_profile"]
  image_id                    = "${data.aws_ami.ecs_ami.id}"
  instance_type               = "${var.instance_type}"
  key_name                    = "${var.key_name}"
  iam_instance_profile        = "${aws_iam_instance_profile.ecs_profile.name}"
  security_groups             = ["${aws_security_group.ecs.id}","${var.appserver_sg}"]
  associate_public_ip_address = "true"

  ebs_block_device {
    device_name           = "/dev/xvdcz"
    volume_size           = "${var.docker_storage_size}"
    volume_type           = "gp2"
    delete_on_termination = true
  }

  user_data = "${data.template_file.user_data.rendered}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "ecs" {
  name_prefix          = "asg-${aws_launch_configuration.ecs.name}-"
  vpc_zone_identifier  = ["${var.subnet_a}","${var.subnet_b}"]
  launch_configuration = "${aws_launch_configuration.ecs.name}"
  min_size             = "${var.min_servers}"
  max_size             = "${var.max_servers}"
  desired_capacity     = "${var.min_servers}"
  termination_policies = ["OldestLaunchConfiguration", "ClosestToNextInstanceHour", "Default"]

  tags = [{
    key                 = "Name"
    value               = "${aws_ecs_cluster.cluster.name}"
    propagate_at_launch = true
  }]

  lifecycle {
    create_before_destroy = true
  }
}

