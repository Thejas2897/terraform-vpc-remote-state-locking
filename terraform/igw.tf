resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.qicap_vpc.id

  tags = {
    Name = "qicap-igw"
  }
}
