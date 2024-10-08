// provider ***

provider "aws" {
  access_key = ""
  secret_key = ""
  token      = ""
  region     = "us-east-1" //default region
}

//data  ***
# Get the Amazon Linux 2023 AMI
data "aws_ami" "aws-linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023*-x86_64*"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

// resource ***

# Create VPC
resource "aws_vpc" "testVPC" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "testVPC"
  }
}

# Create Public Subnet
resource "aws_subnet" "Public1" {
  vpc_id                  = aws_vpc.testVPC.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
  tags = {
    Name = "Public1"
  }
}



# Create Security Group
resource "aws_security_group" "AllowSSHandWeb" {
  vpc_id = aws_vpc.testVPC.id
  name   = "AllowSSHandWeb"

  # Allow SSH from all sources
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # Allow HTTP from all sources
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic (egress rules)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "AllowSSHandWeb"
  }
}

# EC2 Instance
resource "aws_instance" "tfTest" {
  ami             = data.aws_ami.aws-linux.id
  instance_type   = "t2.micro"
  subnet_id       = aws_subnet.Public1.id
  key_name        = "vockey"
  vpc_security_group_ids = [aws_security_group.AllowSSHandWeb.id]


  root_block_device {
    volume_size = 8
    volume_type = "gp2"
  }

  tags = {
    Name = "tfTest"
  }
}


//output ***

# Output the EC2 public DNS
output "aws_instance_public_dns" {
  value = aws_instance.tfTest.public_dns
}
