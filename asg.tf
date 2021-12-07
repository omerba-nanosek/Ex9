locals {
  user_data = <<EOF
#!/usr/bin/bash
sudo yum install docker -y
sudo systemctl enable docker
sudo systemctl start docker
sudo docker run -d \
-e DB_HOST=<the rds instance address>:3306 \
-e DB_DATABASE=bookstack \
-e DB_USERNAME=bookstack \
-e DB_PASSWORD=secret123 \
-p 8080:80 \
solidnerd/bookstack:0.27.5
EOF
}

resource "aws_launch_template" "my-lt" {
  name = "my-lt"
  image_id = "ami-0b898040803850657"
  instance_type = "t2.micro"
  vpc_security_group_ids = [data.aws_security_group.default-sg.id, aws_security_group.my-sg.id]
  user_data = base64encode(local.user_data)
  depends_on = [aws_db_instance.bookstack]
}

resource "aws_autoscaling_group" "my-asg" {
  max_size = 1
  min_size = 1
  vpc_zone_identifier = data.aws_subnet_ids.default-subnets.ids
  load_balancers = [aws_elb.my-elb.name]
  launch_template {
    name = aws_launch_template.my-lt.name
    version = aws_launch_template.my-lt.latest_version
  }
}

resource "aws_autoscaling_policy" "my-acp" {
  autoscaling_group_name = aws_autoscaling_group.my-asg.name
  name                   = "my-acp"
  adjustment_type = "ChangeInCapacity"
  scaling_adjustment = 3
}