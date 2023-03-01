data "aws_availability_zones" "available" {}
resource "aws_vpc" "myVpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
}

resource "aws_internet_gateway" "main" {
 vpc_id      = "${aws_vpc.myVpc.id}"
}

resource "aws_eip" "one" {
  vpc                       = true
}

resource "aws_nat_gateway" "example" {
  connectivity_type = "public"
  subnet_id         = aws_subnet.public[0].id
  allocation_id = aws_eip.one.id
}

resource "aws_subnet" "public" {
  count = 2
  vpc_id      = "${aws_vpc.myVpc.id}"
  availability_zone = data.aws_availability_zones.availability_zones.names[count.index]
  cidr_block = cidrsubnet(aws_vpc.myVpc.cidr_block, 8, count.index)
  map_public_ip_on_launch = true
}

resource "aws_subnet" "private" {
  count = 2
  vpc_id      = "${aws_vpc.myVpc.id}"
  availability_zone = data.aws_availability_zones.availability_zones.names[count.index]
  cidr_block = cidrsubnet(aws_vpc.myVpc.cidr_block, 8, count.index + 3)
  map_public_ip_on_launch = true
}


resource "aws_security_group" "SG_LB" {
  name        = "Team-Two-Security-Group"
  description = "Allows security access"
  vpc_id      = "${aws_vpc.myVpc.id}"
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
    ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
    ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
    ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.myVpc.id
}

resource "aws_route" "name" {
  route_table_id = aws_route_table.public.id
  destination_cidr_block = var.destination_cidr_block
  gateway_id = aws_internet_gateway.main.id
}

resource "aws_route_table_association" "public" {
  count = 2
  subnet_id = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public.id
}


data "aws_ami" "aws-ami" {
  most_recent = true
}

resource "aws_launch_configuration" "as_conf" {
  name_prefix   = "Team-Two-Launch-Config"
  image_id      = data.aws_ami.linux2.id
  instance_type = var.instance_type
  security_groups = ["${aws_security_group.SG_LB.id}"]
  user_data = file("userdata.sh")
  
    lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "asg-aws" {
  name                 = "Team-Two-autoscalegroup"
  launch_configuration = aws_launch_configuration.as_conf.name
  min_size             = 2
  max_size             = 3
  vpc_zone_identifier = [aws_subnet.public[0].id, aws_subnet.public[1].id]
    tag {
    key                 = "Name"
    value               = "Team Two"
    propagate_at_launch = true
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_default_network_acl" "default" {
  default_network_acl_id = aws_vpc.myVpc.default_network_acl_id
  
  ingress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  egress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }
}


resource "aws_alb" "loadbalancer" {
  name               = "Team-Two-aws-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.SG_LB.id]
  subnets            = [for subnet in aws_subnet.public : subnet.id]
  tags = {
    Environment = "production"
    name = "Team Two EC2"
  }
}

resource "aws_elasticache_cluster" "elasticache_cluster" {
  cluster_id           = "team-two-cluster"
  engine               = "memcached"
  node_type            = "cache.m4.large"
  num_cache_nodes      = 2
  parameter_group_name = "default.memcached1.6"
  port                 = 11211
}

resource "aws_db_subnet_group" "default" {
  name       = "main"
  subnet_ids = [aws_subnet.private[0].id, aws_subnet.private[1].id]

  tags = {
    Name = "My DB subnet group"
  }
}

resource "aws_db_instance" "aws_rds" {
  allocated_storage    = 10
  db_name              = "wordpress"
  identifier         = "team2"
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t3.micro"
  username             = "wordpress"
  password             = "password"
  parameter_group_name = "default.mysql5.7"
  skip_final_snapshot  = true
  max_allocated_storage = 100
  db_subnet_group_name = aws_db_subnet_group.default.name
}