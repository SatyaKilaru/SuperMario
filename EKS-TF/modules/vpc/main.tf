# ---------------------------------------------------------------------------
# VPC / Subnet lookup
#
# By default this module uses the account's default VPC and its subnets,
# matching the original project behavior. For real environments (staging,
# prod), pass an explicit vpc_id and subnet_ids from the caller instead.
# ---------------------------------------------------------------------------
data "aws_vpc" "selected" {
  count   = var.vpc_id == null ? 1 : 0
  default = var.use_default_vpc
  id      = var.vpc_id
}

data "aws_subnets" "selected" {
  count = length(var.subnet_ids) == 0 ? 1 : 0

  filter {
    name   = "vpc-id"
    values = [var.vpc_id == null ? data.aws_vpc.selected[0].id : var.vpc_id]
  }
}

locals {
  vpc_id     = var.vpc_id != null ? var.vpc_id : data.aws_vpc.selected[0].id
  subnet_ids = length(var.subnet_ids) > 0 ? var.subnet_ids : data.aws_subnets.selected[0].ids
}
