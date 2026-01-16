resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.qicap_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "ap-south-1a"

  tags = {
    Name = "qicap-public-subnet"
  }
}
