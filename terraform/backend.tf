terraform {
  backend "s3" {
    bucket         = "qicap-tfstate-1768555990"
    key            = "vpc/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "tf-lock-1768555990"
  }
}
