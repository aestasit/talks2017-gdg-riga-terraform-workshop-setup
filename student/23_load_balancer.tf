
resource "aws_alb" "cluster_lb" {
  name            = "${var.project_name}-lb"
  internal        = false
  security_groups = [ "${data.aws_security_group.workshop_security_group.id}" ]
  subnets         = [ "${data.aws_subnet.workshop_subnet_primary.id}", "${data.aws_subnet.workshop_subnet_secondary.id}" ]
}

resource "aws_alb_target_group" "cluster_target_group" {
  name     = "elasticsearch"
  port     = 9200
  protocol = "HTTP"
  vpc_id   = "${data.aws_subnet.workshop_subnet_primary.vpc_id}"
}

resource "aws_alb_target_group_attachment" "cluster_target" {
  count = "${var.node_count}"
  target_group_arn = "${aws_alb_target_group.cluster_target_group.arn}"
  target_id        = "${aws_instance.cluster_node.*.id[count.index]}"
  port             = 9200
}

resource "aws_alb_listener" "cluster_front_end" {
  load_balancer_arn = "${aws_alb.cluster_lb.arn}"
  port              = "9200"
  protocol          = "HTTP"
  default_action {
    target_group_arn = "${aws_alb_target_group.cluster_target_group.arn}"
    type             = "forward"
  }
}

