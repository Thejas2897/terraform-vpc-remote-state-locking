# Commands (init, plan, apply, state, drift)

## Terraform flow

- terraform fmt
- terraform init
- terraform plan
- terraform apply

## Remote backend migration
- terraform init -migrate-state

## State inspection
- terraform state list
- terraform show

## Drift detection
- Manual change in AWS Console (example: change VPC tag)
- Then run:
terraform plan
- Terraform will show the diff (drift).

## AWS verification
- aws ec2 describe-vpcs --filters Name=tag:Name,Values=qicap-vpc
- aws s3 ls | grep tfstate
- aws dynamodb list-tables | grep tf-lock