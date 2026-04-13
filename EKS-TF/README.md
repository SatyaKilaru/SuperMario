# EKS Terraform — Modular Infrastructure

Reusable Terraform modules to provision an Amazon EKS cluster (control plane + managed node group) across multiple environments (`dev`, `staging`, `prod`).

The original single-file configuration has been refactored into small, composable modules, and each environment is an independent Terraform root with its own state file and variable values.

---

## 1. Repository Layout

```
EKS-TF/
├── modules/                       # Reusable building blocks
│   ├── iam/                       # IAM roles for cluster + nodes
│   ├── vpc/                       # VPC / subnet lookup helpers
│   ├── eks-cluster/               # EKS control plane
│   └── eks-node-group/            # Managed node group
│
├── environments/                  # One root module per environment
│   ├── dev/
│   │   ├── main.tf                # Composes the modules
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   ├── provider.tf
│   │   ├── backend.tf             # Remote state (S3) — per-env key
│   │   └── terraform.tfvars       # Env-specific values
│   ├── staging/
│   └── prod/
│
└── README.md
```

### Why this structure?

- **`modules/`** holds pure, reusable logic. No hardcoded environment values.
- **`environments/<env>/`** is the "root" you `terraform apply` against. Each env has:
  - its own **state file** (S3 key `eks/<env>/terraform.tfstate`)
  - its own **tfvars** (node sizing, VPC, endpoints, tags)
  - the exact same `main.tf` wiring — only inputs differ

You never edit the modules to change an environment — you change `terraform.tfvars`.

---

## 2. Modules

| Module | Purpose | Key Inputs | Key Outputs |
|---|---|---|---|
| [modules/iam](modules/iam/) | Creates the EKS cluster role and the worker-node role with the standard AWS-managed policies attached | `name_prefix`, `tags` | `cluster_role_arn`, `node_role_arn`, policy-attachment handles |
| [modules/vpc](modules/vpc/) | Resolves a VPC + subnet list. Defaults to the account's default VPC (dev), or accepts an explicit `vpc_id` / `subnet_ids` (staging/prod) | `vpc_id`, `subnet_ids`, `use_default_vpc` | `vpc_id`, `subnet_ids` |
| [modules/eks-cluster](modules/eks-cluster/) | Provisions the EKS control plane | `cluster_name`, `cluster_role_arn`, `subnet_ids`, `kubernetes_version`, endpoint access flags | `cluster_name`, `cluster_endpoint`, `cluster_certificate_authority_data` |
| [modules/eks-node-group](modules/eks-node-group/) | Provisions a managed node group attached to the cluster | `cluster_name`, `node_role_arn`, `subnet_ids`, `instance_types`, scaling config | `node_group_id`, `node_group_arn` |

---

## 3. Prerequisites

1. **AWS account** with permission to create IAM roles, VPC data access, EKS clusters and node groups.
2. **AWS CLI v2** configured (`aws configure`) or environment variables `AWS_ACCESS_KEY_ID` / `AWS_SECRET_ACCESS_KEY` / `AWS_REGION`.
3. **Terraform >= 1.3.0**.
4. **kubectl** (to interact with the cluster once it's up).
5. An **S3 bucket** for remote state. Bucket name must match `bucket` in each env's `backend.tf`. (Optionally, a DynamoDB table for state locking.)

Quick install commands (Linux):

```bash
# Terraform
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt-get update && sudo apt-get install -y terraform

# AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && unzip awscliv2.zip && sudo ./aws/install

# kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
```

---

## 4. One-Time Setup (remote state bucket)

Each environment stores state remotely in S3. Create the bucket **once** before `terraform init`:

```bash
aws s3api create-bucket \
  --bucket mybucket123 \
  --region ap-south-1 \
  --create-bucket-configuration LocationConstraint=ap-south-1

aws s3api put-bucket-versioning \
  --bucket mybucket123 \
  --versioning-configuration Status=Enabled
```

If you want state locking (recommended for shared teams):

```bash
aws dynamodb create-table \
  --table-name terraform-locks \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region ap-south-1
```

Then uncomment `dynamodb_table` and `encrypt` in each env's `backend.tf`.

> **Note:** the bucket name is currently `mybucket123` in `environments/*/backend.tf`. Change it to a globally-unique bucket you own before running `terraform init`.

---

## 5. Deploying an Environment

The workflow is identical for every environment — only the working directory changes.

### Dev

```bash
cd environments/dev

# 1. Initialize: downloads providers + configures the S3 backend
terraform init

# 2. Review what will be created
terraform plan -var-file=terraform.tfvars

# 3. Apply
terraform apply -var-file=terraform.tfvars
# (type "yes" to confirm)
```

### Staging

```bash
cd environments/staging
terraform init
terraform apply -var-file=terraform.tfvars
```

### Prod

```bash
cd environments/prod
terraform init
terraform apply -var-file=terraform.tfvars
```

Each environment maintains its own state file, so applies are fully isolated.

---

## 6. Connecting to the Cluster

After a successful apply:

```bash
# Grab the region and cluster name from outputs
cd environments/dev
CLUSTER_NAME=$(terraform output -raw cluster_name)
REGION=$(terraform output -raw region)

# Update kubeconfig
aws eks update-kubeconfig --region "$REGION" --name "$CLUSTER_NAME"

# Verify
kubectl get nodes
kubectl get pods -A
```

---

## 7. Customizing an Environment

Edit `environments/<env>/terraform.tfvars`. Common knobs:

| Variable | Purpose |
|---|---|
| `region` | AWS region |
| `vpc_id` / `subnet_ids` | Use an explicit VPC (required for prod) |
| `use_default_vpc` | Fall back to the default VPC (dev) |
| `kubernetes_version` | Pin a specific K8s version (e.g. `"1.29"`) |
| `instance_types` | Node EC2 types, e.g. `["t3.large"]` |
| `capacity_type` | `ON_DEMAND` or `SPOT` |
| `desired_size` / `min_size` / `max_size` | Node group scaling |
| `endpoint_public_access` / `endpoint_private_access` | Control plane API exposure |
| `tags` | Extra tags merged into the common tag set |

The defaults per environment are:

| | dev | staging | prod |
|---|---|---|---|
| Instance type | `t3.medium` | `t3.large` | `t3.large` |
| Desired nodes | 1 | 2 | 3 |
| Public API | yes | yes | **no** |
| Private API | no | yes | yes |
| VPC | default | default (override recommended) | **explicit required** |

---

## 8. Adding a New Environment

To add, say, `qa`:

```bash
cp -r environments/dev environments/qa
# edit environments/qa/backend.tf     -> change key to eks/qa/terraform.tfstate
# edit environments/qa/terraform.tfvars -> set environment = "qa" and sizing
cd environments/qa
terraform init
terraform apply -var-file=terraform.tfvars
```

No module changes required.

---

## 9. Destroying an Environment

```bash
cd environments/<env>
terraform destroy -var-file=terraform.tfvars
```

Terraform will tear down the node group first, then the cluster, then the IAM roles, thanks to the `depends_on` wiring in the modules.

---

## 10. Troubleshooting

- **`InvalidParameterException: Subnets specified must be in at least two different AZs`** — EKS requires subnets spanning ≥ 2 AZs. If you're using the default VPC, this usually works; otherwise set `subnet_ids` explicitly.
- **`AccessDenied` on S3 backend init** — your AWS credentials don't have `s3:GetObject` / `s3:PutObject` on the state bucket, or the bucket doesn't exist yet (see §4).
- **State lock stuck** — if a previous apply crashed, run `terraform force-unlock <LOCK_ID>` (only after confirming no one else is applying).
- **Cluster stuck in `CREATING`** — this is normal; EKS takes 10–15 minutes. Watch it with `aws eks describe-cluster --name <name> --query cluster.status`.

---

## 11. Migrating From the Old Layout

The previous single-file config (`main.tf`, `backend.tf`, `provider.tf` at the root of `EKS-TF/`) is replaced by `environments/dev/`. If you already applied the old version and want to preserve the running cluster:

1. Update the old `backend.tf` key to match `eks/dev/terraform.tfstate`, then `terraform init -migrate-state`.
2. `terraform state mv` the old resources to their new module addresses, e.g.:
   ```
   terraform state mv aws_iam_role.example                 module.iam.aws_iam_role.cluster
   terraform state mv aws_iam_role.example1                module.iam.aws_iam_role.node
   terraform state mv aws_eks_cluster.example              module.eks_cluster.aws_eks_cluster.this
   terraform state mv aws_eks_node_group.example           module.eks_node_group.aws_eks_node_group.this
   # ...and the policy attachments
   ```
3. `terraform plan` — it should report **no changes**. If it does, reconcile name/tag differences before applying.

If you don't need to preserve the cluster, simply `terraform destroy` against the old config and then `terraform apply` in `environments/dev/`.
