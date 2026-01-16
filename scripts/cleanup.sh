#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TF_DIR="${ROOT_DIR}/terraform"

if [[ ! -f "${ROOT_DIR}/scripts/.env.local" ]]; then
  echo "❌ Missing scripts/.env.local. If you deleted it, manually clean resources in AWS."
  exit 1
fi

# shellcheck disable=SC1091
source "${ROOT_DIR}/scripts/.env.local"

cd "${TF_DIR}"

echo "==> Terraform destroy (removes VPC, subnet, IGW, route table)..."
terraform destroy -auto-approve || {
  echo "⚠️ terraform destroy failed. Fix manually before deleting backend."
  exit 1
}

echo "==> Deleting DynamoDB lock table..."
aws dynamodb delete-table --table-name "${LOCK_TABLE}" --region "${REGION}" >/dev/null || true

echo "==> Deleting S3 state bucket (must be empty)..."
# Remove objects first
aws s3 rm "s3://${TFSTATE_BUCKET}" --recursive >/dev/null || true
aws s3api delete-bucket --bucket "${TFSTATE_BUCKET}" --region "${REGION}" >/dev/null || true

echo "==> Removing local env marker..."
rm -f "${ROOT_DIR}/scripts/.env.local"

echo "✅ Cleanup complete (AWS resources removed)."
