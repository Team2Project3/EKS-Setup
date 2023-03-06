resource "aws_instance" "main" {
  ami                    = data.aws_ssm_parameter.instance_ami.value
  instance_type          = "t2.micro"
  key_name               = "terraform_key"
  subnet_id              = aws_subnet.public[0].id
  vpc_security_group_ids = ["aws_security_group.main.id"]
  tags = {
    "Name" = "${var.default_tags.env}-ec2"
  }
  user_data = base64encode(file("C:\\Users\\Jerem\\OneDrive\\Desktop\\AWS-SkillStorm\\Project 3\\New folder\\userdata.sh"))
}
