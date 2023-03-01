data "aws_ami" "linux2" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

data "aws_availability_zones" "availability_zones" {
  state = "available"
}