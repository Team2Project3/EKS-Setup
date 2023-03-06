data "aws_availability_zones" "availability_zone" {
  state = "available"
}

data "aws_ssm_parameter" "instance_ami" {
  name = "/aws/service/canonical/ubuntu/server/20.04/stable/20211129/amd64/hvm/ebs-gp2/ami-id"
}