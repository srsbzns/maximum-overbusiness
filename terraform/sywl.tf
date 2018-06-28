resource "aws_security_group" "web-server" {
  name = "web-server"
  description = "For web servers, ports 80/443 inbound"
}

resource "aws_security_group_rule" "allow_HTTP" {
  type = "ingress"
  from_port = "80"
  to_port = "80"
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.web-server.id}"
}

resource "aws_security_group_rule" "allow_HTTPS" {
  type = "ingress"
  from_port = "443"
  to_port = "443"
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.web-server.id}"
}

resource "aws_instance" "sywl-web" {
  ami           = "ami-fdf7a982"
  instance_type = "t2.micro"
  security_groups = ["web-server"]
}
