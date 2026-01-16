# Terraform IaC — AWS VPC + Remote State Locking (S3 + DynamoDB)

Provisioned an AWS VPC using Terraform with S3/DynamoDB for state locking and consistent, secure infra updates.

This repo proves:
- Terraform IaC fundamentals
- Remote backend (S3) for centralized state
- DynamoDB locking (team-safe applies)
- Drift detection via `terraform plan`
- Real AWS provisioning

> ⚠️ Costs: small but non-zero. Clean up after.

---

## What is built
VPC stack:
- VPC (10.0.0.0/16)
- Internet Gateway
- Public Subnet (10.0.1.0/24)
- Route table + association (0.0.0.0/0 → IGW)

Remote state stack:
- S3 bucket (unique name generated)
- DynamoDB table for state lock

---