resource "aws_elb" "my-elb" {
  name = "my-elb"
  availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]

  listener {
    instance_port     = 8080
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    interval            = 30
    target              = "HTTP:8080/"
    timeout             = 3
    unhealthy_threshold = 2
  }
}
