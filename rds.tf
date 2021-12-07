resource "aws_security_group" "my-sg" {
  name = "my-sg"
  ingress {
    from_port = 3306
    protocol  = "tcp"
    to_port   = 3306
  }
}

data "aws_security_group" "default-sg" {
  name = "default"
}

data "aws_vpc" "default-vpc" {
  default = true
}

data "aws_subnet_ids" "default-subnets" {
  vpc_id = data.aws_vpc.default-vpc.id
}

resource "aws_db_subnet_group" "db-subnet" {
  subnet_ids = data.aws_subnet_ids.default-subnets.ids
}

resource "aws_db_instance" "bookstack" {
  engine = "mysql"
  engine_version = "5.7"
  instance_class = "db.t2.micro"
  name = "bookstack"
  username = "bookstack"
  password = "secret123"
  vpc_security_group_ids = [aws_security_group.my-sg.id, data.aws_security_group.default-sg.id]
  db_subnet_group_name = aws_db_subnet_group.db-subnet.id
  skip_final_snapshot = true
  allocated_storage = 5
  storage_type = "gp2"
}