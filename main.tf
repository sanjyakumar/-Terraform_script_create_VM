# Define provider and AWS region
provider "aws" {
  region = "ap-south-1"  # Replace with your desired region
}

#create vpc
resource "aws_vpc" "demo_vpc" {
    cidr_block = "10.0.0.0/16"
    instance_tenancy = "default"
    tags = {
        name = "demo_vpc"
    }
}

output "aws_vpc" {
    value = aws_vpc.demo_vpc.id
}

#add internetgateway
resource "aws_internet_gateway" "demo_internet_gateway" {
    vpc_id = aws_vpc.demo_vpc.id
    tags = {

       name = "trm_internetgetway"

    }
}

#create route table
resource "aws_default_route_table" "demo_route_table" {
    default_route_table_id  = aws_vpc.demo_vpc.default_route_table_id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.demo_internet_gateway.id
    }
}

#Security group
resource "aws_security_group" "terraform_ec2_private_sg1" {
    vpc_id = aws_vpc.demo_vpc.id
    name = "terraform_ec2_private_sg1"
    ingress {
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 22
    to_port     = 22
  }
    ingress {
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 80
    to_port     = 80

  }
}

#create subnet
resource "aws_subnet" "terraform_demo_subnet_1" {
    vpc_id = aws_vpc.demo_vpc.id
    cidr_block = "10.0.0.0/17"
    availability_zone = "ap-south-1a"
    tags = {
        name = "terraform_demo_subnet_1"
    }

}

output "aws_subnet" {
    value = aws_subnet.terraform_demo_subnet_1.id           
}

# Create an EC2 instance
resource "aws_instance" "my_instance" {
  ami           = "AMI ID"                                 #  your desired AMI ID
  instance_type = "t2.micro"                               #  your desired instance type
  key_name      = "SSH Key_pair"                           #  your SSH key pair name
  vpc_security_group_ids = ["${aws_security_group.terraform_ec2_private_sg1.id}"]
  subnet_id = aws_subnet.terraform_demo_subnet_1.id
  count = 1                                                # Number of instance create 
  associate_public_ip_address = true

  tags = {
    Name = "my-instance"                                   # Instance name 
  }
}

# Create an S3 bucket
resource "aws_s3_bucket" "my_bucket" {
  bucket = "my-object-store-bucket"                       # your desired bucket name

  tags = {
    Name = "my-bucket"
  }
}
