project     = "supermario"
environment = "staging"
region      = "ap-south-1"

# For staging, prefer explicit networking. Fill in real IDs before apply.
use_default_vpc = true
# vpc_id     = "vpc-xxxxxxxx"
# subnet_ids = ["subnet-aaaa", "subnet-bbbb"]

instance_types = ["t3.large"]
capacity_type  = "ON_DEMAND"
desired_size   = 2
min_size       = 2
max_size       = 4

endpoint_public_access  = true
endpoint_private_access = true

tags = {
  CostCenter = "engineering"
}
