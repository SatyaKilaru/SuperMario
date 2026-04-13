terraform {
  backend "s3" {
    bucket = "mybucket123"
    key    = "eks/dev/terraform.tfstate"
    region = "ap-south-1"
    # dynamodb_table = "terraform-locks" # optional: enable state locking
    # encrypt        = true
  }
}
