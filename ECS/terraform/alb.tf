resource "aws_security_group" "alb" {
  name        = "ecs-alb-sg-${var.ecs_cluster_name}"
  description = "ECS ALB SG"
  vpc_id      = "${var.vpc_id}"
  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "ecs-alb-sg-${var.ecs_cluster_name}"
  }
}
resource "aws_alb" "alb" {
  name            = "${var.ecs_cluster_name}"
  internal        = false
  security_groups = ["${aws_security_group.alb.id}"]
  subnets         = ["${var.subnet_a}","${var.subnet_b}"]
}


resource "aws_alb_listener" "alb_listener" {
  load_balancer_arn = "${aws_alb.alb.id}"
  port              = "5000"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.app_frontend_targets.arn}"
    type             = "forward"
  }
}

resource "aws_alb_target_group" "app_frontend_targets" {
  name      = "app-frontend-tg-${var.infra_version}"
  port      = "5000"
  protocol  = "HTTP"
  vpc_id    = "${var.vpc_id}"
health_check {
    healthy_threshold   = 2
    interval            = 60
    path                = "/"
    timeout             = 10
    unhealthy_threshold = 5
  }
}

resource "aws_alb_listener_rule" "alb_frontend_rule" {
  listener_arn = "${aws_alb_listener.alb_listener.arn}"
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = "${aws_alb_target_group.app_frontend_targets.arn}"
  }
  condition {
    field  = "path-pattern"
    values = ["/*"]
  }
}

