terraform {
  backend "s3" {
    bucket = "mybucket123"
    key    = "eks/prod/terraform.tfstate"
    region = "ap-south-1"
    # dynamodb_table = "terraform-locks"
    # encrypt        = true
  }
}
