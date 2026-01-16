# Failure Scenarios (interview gold)

## 1) Two engineers run `terraform apply` at the same time
**Symptom**
- Error about state lock / ConditionalCheckFailedException

**Why**
- DynamoDB lock prevents concurrent mutation of state.

**Fix**
- Wait for the other apply to finish.
- If truly stuck:
  ```bash
  terraform force-unlock <LOCK_ID>
  ```


## 2) Bucket name already exists
**Symptom**
- BucketAlreadyExists from AWS

**Cause**
- S3 bucket names are global.

**Fix**
- Use a unique bucket name (this repo auto-generates one in scripts).

## 3) Wrong region / resources not found
**Symptom**
- Terraform creates in one region, AWS CLI checks another

**Fix**
- Ensure:
AWS CLI default region matches provider region
provider.tf uses intended region

## 4) Someone manually changes AWS resources (drift)
**Symptom**
- terraform plan shows changes

**Fix**
- Reconcile by applying desired state:
```bash
terraform apply
```

- Or accept manual change by updating code (best practice: code is source of truth).

## 5) S3 backend deleted / missing
**Symptom**
- terraform init fails

**Fix**
- Recreate bucket/table and re-init.
- In real teams, state bucket is protected via IAM + retention policies.
