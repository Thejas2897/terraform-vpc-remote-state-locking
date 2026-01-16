resource "aws_vpc" "qicap_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "qicap-vpc"
  }
}
