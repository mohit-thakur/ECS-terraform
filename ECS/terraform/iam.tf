resource "aws_iam_instance_profile" "ecs_profile" {
  name_prefix = "${var.ecs_cluster_name}-"
  role        = "${aws_iam_role.ecs_role.name}"
  path        = "/"
}

resource "aws_iam_role" "ecs_role" {
  name_prefix = "${var.ecs_cluster_name}-"
  path        = "/"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
      "Service": ["ecs.amazonaws.com", "ec2.amazonaws.com"]

    },
    "Effect": "Allow",
    "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "ecs_policy" {
  name_prefix = "${var.ecs_cluster_name}-"
  description = "A terraform created policy for ECS"
  path        = "/"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecs:CreateCluster",
        "ecs:DeregisterContainerInstance",
        "ecs:DiscoverPollEndpoint",
        "ecs:Poll",
        "ecs:RegisterContainerInstance",
        "ecs:StartTelemetrySession",
        "ecs:Submit*",
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}
resource "aws_iam_role_policy_attachment" "attach_ecs" {
    role       = "${aws_iam_role.ecs_role.name}"
    policy_arn = "${aws_iam_policy.ecs_policy.arn}"
}




resource "aws_iam_role" "ecs_task_role" {
  name_prefix = "${var.ecs_cluster_name}-"
  path        = "/"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
      "Service": ["ecs-tasks.amazonaws.com"]

    },
    "Effect": "Allow",
    "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "ecs_task_role_policy" {
  name_prefix = "${var.ecs_cluster_name}-"
  description = "ecs_task_role_policy"
  path        = "/"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ssm:DescribeParameters",
        "ssm:GetParameter",
        "ssm:GetParameters",
        "ssm:GetParametersByPath"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}
resource "aws_iam_role_policy_attachment" "attach_ecs_task_role" {
    role       = "${aws_iam_role.ecs_task_role.name}"
    policy_arn = "${aws_iam_policy.ecs_task_role_policy.arn}"
}
