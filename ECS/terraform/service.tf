data "template_file" "frontend" {
  template = "${file("task-definitions/frontend.json")}"
  vars {
    ecs_cluster_name = "${var.ecs_cluster_name}"
  }
}
resource "aws_ecs_task_definition" "frontend" {
  family                = "frontend"
  container_definitions = "${data.template_file.frontend.rendered}"
  task_role_arn = "${aws_iam_role.ecs_task_role.arn}"
}


resource "aws_ecs_service" "frontend" {
  name            = "frontend"
  cluster         = "${aws_ecs_cluster.cluster.id}"
  task_definition = "${aws_ecs_task_definition.frontend.arn}"
  depends_on = ["aws_alb_listener_rule.alb_frontend_rule"]
  desired_count   = "${var.frontend_desired_count}"
  load_balancer {
    target_group_arn       = "${aws_alb_target_group.app_frontend_targets.arn}"
    container_name = "frontend"
    container_port = 5000
  }
  
}
