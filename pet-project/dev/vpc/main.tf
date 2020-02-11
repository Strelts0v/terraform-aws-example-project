resource "aws_vpc" "pet_project" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "Pet Project VPC"
  }
}

resource "aws_subnet" "pet_project_subnet_a" {
  vpc_id     = "${aws_vpc.pet_project.id}"
  cidr_block = "10.0.10.0/24"

  tags = {
    Name = "Pet Project VPC Subnet A"
  }
}

resource "aws_subnet" "pet_project_subnet_b" {
  vpc_id     = "${aws_vpc.pet_project.id}"
  cidr_block = "10.0.20.0/24"

  tags = {
    Name = "Pet Project VPC Subnet B"
  }
}
