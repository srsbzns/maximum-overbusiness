resource "aws_security_group" "web-server" {
  name = "web-server"
  description = "For web servers, ports 80 inbound"
}

resource "aws_security_group_rule" "allow_HTTP_in" {
  type = "ingress"
  from_port = "80"
  to_port = "80"
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.web-server.id}"
}

#resource "aws_security_group_rule" "allow_HTTPS_in" {
#  type = "ingress"
#  from_port = "443"
#  to_port = "443"
#  protocol = "tcp"
#  cidr_blocks = ["0.0.0.0/0"]
#  security_group_id = "${aws_security_group.web-server.id}"
#}

resource "aws_security_group" "web-server-lb" {
  name = "web-server-lb"
  description = "For web server load balancer, port 80 outbound"
}

resource "aws_security_group_rule" "allow_HTTP_out" {
  type = "egress"
  from_port = "80"
  to_port = "80"
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.web-server-lb.id}"
}

resource "aws_lb" "fortunato-lb" {
  name = "fortunato-lb"
  load_balancer_type = "application"
  security_groups = ["${aws_security_group.web-server.id}","${aws_security_group.web-server-lb.id}"]
  subnets = ["subnet-26bac843","subnet-fd887cd7"]
}

resource "aws_lb_target_group" "fortunato-lb-tg" {
  name = "fortunato-lb-tg"
  port = "80"
  protocol = "HTTP"
  vpc_id = "vpc-10b7c774"
  health_check = {
    path = "/"
    matcher = "200"
  }
}

resource "aws_lb_listener" "fortunato-lb-listener" {
  load_balancer_arn = "${aws_lb.fortunato-lb.arn}"
  port = "80"
  protocol = "HTTP"
  default_action {
    type = "forward"
    target_group_arn = "${aws_lb_target_group.fortunato-lb-tg.arn}"
  }
}

resource "aws_launch_template" "fortunato-launchtemp" {
  name = "fortunato-launchtemp"
  image_id = "ami-fdf7a982"
  instance_type = "t2.micro"
  key_name = "soyouwannalearn"
  vpc_security_group_ids = ["${aws_security_group.web-server.id}"]
}

resource "aws_autoscaling_group" "fortunato-autoscalegrp" {
  availability_zones = ["us-east-1a","us-east-1b"]
  desired_capacity = 2
  max_size = 2
  min_size = 2
  health_check_type = "EC2"
  target_group_arns = ["${aws_lb_target_group.fortunato-lb-tg.arn}"]
  launch_template = {
    id = "${aws_launch_template.fortunato-launchtemp.id}"
    version = "$$Latest"
  }
}

