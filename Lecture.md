📚 What is Terraform Plan to File?

Normally, when you run:
terraform plan
Terraform calculates what it will change (create, update, delete) — and shows you the output on screen (stdout).
But it does not save it anywhere.

👉 Problem:
	•	If you want exactly the same plan to be applied later, or
	•	You want to share that plan for review before applying, or
	•	You want to prevent drift (environment changes between plan and apply) —

then you need a saved plan file.

🛠️ Terraform Plan to File Workflow

Instead of only planning, we save the plan output to a file:
terraform plan -out=<filename>
Then, later, we can apply exactly that plan:
terraform apply <filename>
✅ This way, the plan and the apply are locked together. No surprises.

🧠 Real-Life Analogy

Imagine you’re a civil engineer.
	•	You first design a building (plan).
	•	You print the blueprint and give it to the construction team.
	•	They build exactly as per the blueprint (apply).

In Terraform:
	•	terraform plan -out=blueprint.plan → saves the blueprint.
	•	terraform apply blueprint.plan → builds using that blueprint.

⸻

🏗️ Real-Life Use Case

In a production environment:
	•	The DevOps team runs terraform plan during the CI pipeline and saves the file.
	•	That plan file is reviewed and approved.
	•	Only after approval, the same file is applied.

🔵 Why?
	•	To avoid differences between planning and applying.
	•	To ensure that no one changes resources accidentally between plan and apply.


🧪 Hands-on Lab Example (Simple)

Let’s create a very small lab: deploy an AWS S3 bucket using plan to file method.

⸻

🎯 LAB Objective

Create an S3 bucket using Terraform, with plan and apply phases separated using a file.

⸻

🧱 Prerequisites
	•	Terraform installed ✅
	•	AWS CLI installed ✅
	•	AWS credentials configured ✅ (e.g., via aws configure)

⸻

📝 Step 1: Create Terraform files

File: main.tf
provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "example" {
  bucket = "my-unique-bucket-20250426-lab"
  acl    = "private"
}

🏗️ Step 2: Initialize Terraform
terraform init
✅ This will download AWS provider plugins.

⸻

📄 Step 3: Create Plan and Save it to a File
terraform plan -out=s3bucket-plan.out
✅ Terraform will calculate all changes, and save the plan into s3bucket-plan.out.

⸻

📥 Step 4: Apply the Saved Plan
terraform apply s3bucket-plan.out
✅ It will not ask again for confirmation of the plan.
✅ It will apply exactly what was planned earlier.

⸻

✅ Step 5: Verify

You can check your AWS S3 console → the bucket will be created.

⸻

🧹 Step 6: Cleanup (Optional)

When done, you want a cleaner way:
terraform plan -destroy -out=destroy-plan.out
terraform apply destroy-plan.out


⸻

🎯 Summary
Step                    Command
Initialize          terraform init
Plan to file        terraform plan -out=planfilename.out
Apply from file     terraform apply planfilename.out
(Optional) Destroy  terraform plan -destroy -out=destroy.out + terraform apply destroy.out


⸻

🎯 Why Use Plan-to-File in Real World?
Situation                                                   Reason
Multi-stage approvals (Dev â†’ QA â†’ Prod)         Plan once, apply later safely
Auditing changes before applying                    Human approval steps
Automation pipelines (CI/CD)                        Better control & rollback
Sensitive production environments                   Avoids accidental drift

🌟 Bonus Tip

You can give meaningful names to your plan files in a pipeline, like:
terraform plan -out=plan-dev-20250426.out
In production, it could even be uploaded to S3 or stored in Git for audit trail.

Let’s extend the lab — now we’ll add a GitHub Actions CI/CD pipeline where:

✅ terraform plan → is saved to a file.
✅ The plan output is shown in GitHub Actions.
✅ Manual Approval is required before applying.
✅ terraform apply uses the saved plan file.


⸻

📦 Final Lab Folder Structure
terraform-s3-lab/
├── .github/
│   └── workflows/
│       └── terraform-pipeline.yml
├── main.tf
├── variables.tf (optional)
├── outputs.tf (optional)
├── README.md

📝 Step 1: Prepare Terraform Code

✅ As before — main.tf:
provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "example" {
  bucket = "my-unique-bucket-20250426-lab"
  acl    = "private"
}
(you can add variables.tf and outputs.tf if you like, but for now, keep it simple)

⸻

🛠️ Step 2: Create GitHub Actions Workflow

✅ Create file:
.github/workflows/terraform-pipeline.yml
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


⸻

🛡️ Step 3: Create Environment in GitHub
	1.	Go to your repository → Settings → Environments.
	2.	Create a new Environment → call it: production
	3.	Inside that environment →
✅ Add a required reviewer (yourself or your teammate).

⸻

🎯 Workflow Summary
Stage                      What Happens
push to main            triggers the workflow
Terraform init          initializes the backend and providers
Terraform plan          saves plan into a file (tfplan.out)
Show plan output        easy for human review in GitHub Actions console
Approval                Hold: waits for manual reviewer in GitHub UI
Apply                   after approval, terraform apply tfplan.out executes


🛠️ Requirements to make this work
	•	Configure AWS credentials in GitHub secrets:
	•	AWS_ACCESS_KEY_ID
	•	AWS_SECRET_ACCESS_KEY
	•	Create Environment in GitHub (called production) and enforce review.

⸻

🌟 Real-World Touch

✅ This method is used by real companies when deploying infrastructure via GitHub CI/CD safely!
✅ Especially for Production Environments.
✅ You can even enhance it by:
    • **Automatically Uploading the .tfplan.out File to S3 for Audit**  
        After saving the plan file, you can upload it to an S3 bucket for audit purposes. Add the following step to your GitHub Actions workflow after the `Terraform Plan (Save to File)` step:  
        ```yaml
        - name: Upload Plan File to S3
            run: |
                aws s3 cp tfplan.out s3://your-audit-bucket-name/tfplan-$(date +%Y%m%d%H%M%S).out
            env:
                AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
                AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        ```

    • **Sending Plan Output to Slack**  
        You can integrate Slack notifications to send the plan output for review. Add the following step to your workflow:  
        ```yaml
        - name: Send Plan Output to Slack
            uses: slackapi/slack-github-action@v1.23.0
            with:
                payload: |
                    {
                        "channel": "#terraform-notifications",
                        "text": "Terraform Plan Output:\n$(terraform show -json tfplan.out | jq -r '.resource_changes[] | .change')"
                    }
            env:
                SLACK_BOT_TOKEN: ${{ secrets.SLACK_BOT_TOKEN }}
        ```

    • **Having Separate Jobs for Plan and Apply**  
        To improve modularity and control, split the workflow into two jobs: one for planning and one for applying.  
        ```yaml
        jobs:
            plan:
                name: "Terraform Plan"
                runs-on: ubuntu-latest
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
                    - name: Upload Plan File to S3
                        run: aws s3 cp tfplan.out s3://your-audit-bucket-name/tfplan-$(date +%Y%m%d%H%M%S).out
                        env:
                            AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
                            AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}

            apply:
                name: "Terraform Apply"
                runs-on: ubuntu-latest
                needs: plan
                steps:
                    - name: Checkout Code
                        uses: actions/checkout@v4
                    - name: Setup Terraform
                        uses: hashicorp/setup-terraform@v3
                        with:
                            terraform_version: 1.8.0
                    - name: Download Plan File from S3
                        run: aws s3 cp s3://your-audit-bucket-name/tfplan-latest.out tfplan.out
                        env:
                            AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
                            AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
                    - name: Terraform Apply from Saved Plan
                        run: terraform apply tfplan.out
        ```
        This ensures that the `apply` job only runs after the `plan` job completes successfully.

 📖 Written By - Raj Mohan Bharathi

        
