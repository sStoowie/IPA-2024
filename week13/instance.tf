resource "aws_security_group" "AllowSSHandWeb" {
  name        = "AllowSSHandWeb"
  description = "Allow incoming SSH and HTTP traffic to EC2 Instance"
  vpc_id      = aws_vpc.testVPC.id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = 6
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = 6
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = merge(local.default_tags, {
    Name = "${var.default_name}-AllowSSHandWeb"
  })
}

resource "aws_instance" "Server1" {
  ami                    = data.aws_ami.aws-linux.id
  instance_type          = "t2.micro"
  key_name               = var.key_name
  subnet_id              = aws_subnet.Public1.id
  vpc_security_group_ids = [aws_security_group.AllowSSHandWeb.id]
  root_block_device {
    volume_size = 8
    volume_type = "gp2"
  }
  tags = merge(local.default_tags, {
    Name = "${var.default_name}-Server1"
  })
}

resource "aws_instance" "Server2" {
  ami                    = data.aws_ami.aws-linux.id
  instance_type          = "t2.micro"
  key_name               = var.key_name
  subnet_id              = aws_subnet.Public1.id
  vpc_security_group_ids = [aws_security_group.AllowSSHandWeb.id]
  root_block_device {
    volume_size = 8
    volume_type = "gp2"
  }
  tags = merge(local.default_tags, {
    Name = "${var.default_name}-Server2"
  })
}
