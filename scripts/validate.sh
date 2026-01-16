#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TF_DIR="${ROOT_DIR}/terraform"

if [[ ! -f "${ROOT_DIR}/scripts/.env.local" ]]; then
  echo "❌ Missing scripts/.env.local. Run setup.sh first."
  exit 1
fi

# shellcheck disable=SC1091
source "${ROOT_DIR}/scripts/.env.local"

echo "==> Validating Terraform state + resources..."
cd "${TF_DIR}"

echo "==> terraform state list:"
terraform state list

echo "==> Checking VPC exists by tag..."
aws ec2 describe-vpcs --filters Name=tag:Name,Values=qicap-vpc --region "${REGION}" | head -n 40

echo "==> Checking S3 bucket exists..."
aws s3 ls | grep -q "${TFSTATE_BUCKET}" && echo "✅ S3 bucket exists: ${TFSTATE_BUCKET}"

echo "==> Checking DynamoDB lock table exists..."
aws dynamodb describe-table --table-name "${LOCK_TABLE}" --region "${REGION}" >/dev/null && echo "✅ DynamoDB table exists: ${LOCK_TABLE}"

echo
echo "✅ Validation passed."
echo "Interview proof: remote backend + lock table + terraform state list shows resources."