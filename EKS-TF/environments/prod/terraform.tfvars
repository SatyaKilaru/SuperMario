project     = "supermario"
environment = "prod"
region      = "ap-south-1"

# Production: ALWAYS use explicit VPC and private subnets.
use_default_vpc = false
# vpc_id     = "vpc-xxxxxxxx"
# subnet_ids = ["subnet-private-a", "subnet-private-b", "subnet-private-c"]

instance_types = ["t3.large"]
capacity_type  = "ON_DEMAND"
desired_size   = 3
min_size       = 3
max_size       = 6

# Production: restrict API endpoint to private.
endpoint_public_access  = false
endpoint_private_access = true

tags = {
  CostCenter = "engineering"
  Critical   = "true"
}
