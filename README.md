# Terraform Infrastructure Deployment

## Overview
This repository contains Terraform code to manage and deploy AWS infrastructure. The workflow includes planning, saving the plan to a file, and applying the saved plan to ensure consistency and prevent drift.

---

## Architecture Diagram

Below is a high-level architecture diagram of the infrastructure managed by this Terraform code:

```
+-------------------+       +-------------------+
|                   |       |                   |
|  AWS VPC Module   |<----->|  AWS TGW Module   |
|                   |       |                   |
+-------------------+       +-------------------+
        |                            |
        v                            v
+-------------------+       +-------------------+
|                   |       |                   |
|  AWS S3 Buckets   |       |  Other Resources  |
|                   |       |                   |
+-------------------+       +-------------------+
```

---

## Network Diagram

Below is a detailed network diagram for the infrastructure, including VPCs, Transit Gateway, and internet flow:

```
+-------------------+       +-------------------+
|                   |       |                   |
|  VPC 1 (Public)   |<----->|  VPC 2 (Private)  |
|                   |       |                   |
+-------------------+       +-------------------+
        |                            |
        v                            v
+-------------------+       +-------------------+
|                   |       |                   |
|  Internet Gateway |       |  NAT Gateway     |
|                   |       |                   |
+-------------------+       +-------------------+
        |                            |
        v                            v
+-------------------+       +-------------------+
|                   |       |                   |
|  Transit Gateway  |<----->|  On-Prem Network  |
|                   |       |                   |
+-------------------+       +-------------------+
```

---

## Workflow

### 1. Initialize Terraform
Run the following command to initialize the Terraform backend and download provider plugins:
```bash
terraform init
```

### 2. Plan and Save to File
Generate a plan and save it to a file for review and later application:
```bash
terraform plan -out=planfile.out
```

### 3. Apply the Saved Plan
Apply the saved plan to ensure consistency:
```bash
terraform apply planfile.out
```

### 4. Destroy Resources (Optional)
If you need to clean up resources, create a destroy plan and apply it:
```bash
terraform plan -destroy -out=destroy.out
terraform apply destroy.out
```

---

## Folder Structure

```
.
├── main.tf
├── variables.tf
├── outputs.tf
├── terraform.tfvars
├── env/
│   ├── dev/
│   │   └── main.tfvars
│   ├── prod/
│   │   └── main.tfvars
│   └── uat/
│       └── main.tfvars
├── modules/
│   ├── tgw/
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   └── vpc/
│       ├── main.tf
│       ├── outputs.tf
│       └── variables.tf
└── README.md
```

---

## CI/CD Workflow

### GitHub Actions Workflow
This repository includes a GitHub Actions workflow to automate the Terraform deployment process. The workflow:

1. **Plans the Infrastructure**: Saves the plan to a file.
2. **Shows the Plan Output**: Displays the plan for review.
3. **Applies the Plan**: Applies the saved plan after manual approval.

### Example Workflow File

```yaml
name: "Terraform Plan and Apply with Approval"

on:
  push:
    branches:
      - main

jobs:
  terraform:
    name: "Terraform Plan & Apply"
    runs-on: ubuntu-latest

    environment:
      name: production
      url: https://aws.amazon.com

    env:
      AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
      AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
      AWS_DEFAULT_REGION: us-east-1

    steps:
      - name: Checkout Code
        uses: actions/checkout@v4

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3
        with:
          terraform_version: 1.8.0

      - name: Terraform Init
        run: terraform init

      - name: Terraform Plan (Save to File)
        run: terraform plan -out=tfplan.out

      - name: Show Terraform Plan Output
        run: terraform show tfplan.out

      - name: Terraform Apply from Saved Plan
        run: terraform apply tfplan.out
```

---

## Best Practices

- **Use Plan Files**: Always save the plan to a file to ensure consistency.
- **Environment-Specific Variables**: Use `main.tfvars` files for environment-specific configurations.
- **CI/CD Pipelines**: Automate the workflow using GitHub Actions or other CI/CD tools.
- **Audit Trails**: Save plan files to an S3 bucket or version control for auditing purposes.

---

## Prerequisites

- Terraform installed ✅
- AWS CLI installed ✅
- AWS credentials configured ✅ (e.g., via `aws configure`)

---

## Contact
For any issues or questions, please contact the repository maintainer.