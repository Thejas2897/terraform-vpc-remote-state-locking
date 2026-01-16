#!/usr/bin/env bash
set -euo pipefail

# --------
# Configuration
# --------
REGION="${AWS_REGION:-ap-south-1}"
AZ="${AWS_AZ:-ap-south-1a}"

# Unique bucket (S3 is global namespace)
TS="$(date +%s)"
TFSTATE_BUCKET="${TFSTATE_BUCKET:-qicap-tfstate-${TS}}"
LOCK_TABLE="${LOCK_TABLE:-tf-lock-${TS}}"

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TF_DIR="${ROOT_DIR}/terraform"

echo "==> Using region: ${REGION}, AZ: ${AZ}"
echo "==> TFSTATE_BUCKET: ${TFSTATE_BUCKET}"
echo "==> LOCK_TABLE: ${LOCK_TABLE}"

echo "==> Checking AWS identity (must succeed)..."
aws sts get-caller-identity >/dev/null

echo "==> Creating project folder terraform/..."
mkdir -p "${TF_DIR}"
cd "${TF_DIR}"

# --------
# Write Terraform files (complete, no missing)
# --------
cat > provider.tf <<EOF
provider "aws" {
  region = "${REGION}"
}
EOF

cat > vpc.tf <<'EOF'
resource "aws_vpc" "qicap_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "qicap-vpc"
  }
}
EOF

cat > subnet.tf <<EOF
resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.qicap_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "${AZ}"

  tags = {
    Name = "qicap-public-subnet"
  }
}
EOF

cat > igw.tf <<'EOF'
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.qicap_vpc.id

  tags = {
    Name = "qicap-igw"
  }
}
EOF

cat > route_table.tf <<'EOF'
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.qicap_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "qicap-public-rt"
  }
}

resource "aws_route_table_association" "assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}
EOF

echo "==> Creating S3 bucket for remote state..."
# Note: ap-south-1 requires LocationConstraint
aws s3api create-bucket \
  --bucket "${TFSTATE_BUCKET}" \
  --region "${REGION}" \
  --create-bucket-configuration LocationConstraint="${REGION}" >/dev/null

echo "==> Creating DynamoDB table for state locking..."
aws dynamodb create-table \
  --table-name "${LOCK_TABLE}" \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --provisioned-throughput ReadCapacityUnits=1,WriteCapacityUnits=1 >/dev/null

echo "==> Waiting for DynamoDB table to be ACTIVE..."
aws dynamodb wait table-exists --table-name "${LOCK_TABLE}"

echo "==> Writing backend.tf (generated, because backend blocks can't use vars)..."
cat > backend.tf <<EOF
terraform {
  backend "s3" {
    bucket         = "${TFSTATE_BUCKET}"
    key            = "vpc/terraform.tfstate"
    region         = "${REGION}"
    dynamodb_table = "${LOCK_TABLE}"
  }
}
EOF

echo "==> Initializing Terraform (remote backend)..."
terraform init

echo "==> Formatting..."
terraform fmt -recursive

echo "==> Planning..."
terraform plan

echo "==> Applying..."
terraform apply -auto-approve

echo
echo "✅ Setup complete."
echo "State bucket: ${TFSTATE_BUCKET}"
echo "Lock table:   ${LOCK_TABLE}"
echo "Next: run scripts/validate.sh"
echo
echo "NOTE: These values are also stored in scripts/.env.local for cleanup."
echo "TFSTATE_BUCKET=${TFSTATE_BUCKET}" > "${ROOT_DIR}/scripts/.env.local"
echo "LOCK_TABLE=${LOCK_TABLE}"       >> "${ROOT_DIR}/scripts/.env.local"
echo "REGION=${REGION}"               >> "${ROOT_DIR}/scripts/.env.local"