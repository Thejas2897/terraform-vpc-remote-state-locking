# Architecture

## Remote State Pattern
- S3 bucket: holds `terraform.tfstate`
- DynamoDB table: enforces state lock (LockID)

Why:
- Prevents concurrent applies from corrupting state
- Allows multiple engineers/agents to share the same truth

## VPC Pattern
VPC 10.0.0.0/16
- Public subnet 10.0.1.0/24
- Internet Gateway
- Route table with default route 0.0.0.0/0 → IGW
- Route association to public subnet

## Truth boundaries
- This is a **foundational** VPC demo (not multi-AZ, not NAT, not private subnets)
- No modules, no complex routing, no HA.
