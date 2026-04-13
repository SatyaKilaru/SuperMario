project     = "supermario"
environment = "dev"
region      = "ap-south-1"

# Use the account's default VPC for dev.
use_default_vpc = true

# Node group sizing (dev: minimal)
instance_types = ["t3.medium"]
capacity_type  = "ON_DEMAND"
desired_size   = 1
min_size       = 1
max_size       = 2

endpoint_public_access  = true
endpoint_private_access = false

tags = {
  CostCenter = "engineering"
}
