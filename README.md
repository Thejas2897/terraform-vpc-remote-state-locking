# AWS VPC — Terraform IaC with Remote State Locking

Provisions a production-pattern AWS VPC using Terraform,
with S3 remote state and DynamoDB locking to prevent
concurrent apply conflicts in team environments.

Built to validate the full state management workflow
an SRE would use before introducing Terraform into
a shared infrastructure pipeline.

---

## Infrastructure provisioned

**VPC stack**
- VPC (10.0.0.0/16)
- Internet Gateway
- Public Subnet (10.0.1.0/24)
- Route table + association (0.0.0.0/0 → IGW)

**Remote state stack**
- S3 bucket with versioning (state history + rollback)
- DynamoDB table for state locking (prevents concurrent applies)

---

## Why remote state locking matters

Without a lock, two engineers running `terraform apply`
simultaneously can corrupt the state file — leading to
infrastructure drift that's difficult to detect and 
expensive to recover from.

This setup ensures only one apply runs at a time.
The DynamoDB lock is automatically released on success
or failure — no manual cleanup needed.

---

## Drift detection

Run `terraform plan` against live infrastructure to
surface any manual changes made outside Terraform.
This repo includes runbook documentation for integrating
plan checks into a CI pipeline as a drift detection gate.

---

## Tradeoffs considered

- **S3 vs Terraform Cloud for state**: S3 gives full
  control and zero vendor dependency. Terraform Cloud
  adds a UI and policy features but introduces an
  external dependency. For a single-team AWS shop,
  S3 + DynamoDB is the simpler, more auditable choice.

- **Public subnet only**: This is a minimal networking
  pattern. A production setup would add private subnets,
  NAT Gateway, and separate routing per tier.

---

> This provisions real AWS resources. Run
> `terraform destroy` when done to avoid charges.
