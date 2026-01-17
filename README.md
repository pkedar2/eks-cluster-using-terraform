## Terraform EKS Infrastructure Setup
# Overview

This repository contains a Terraform-based setup to provision AWS infrastructure and an EKS cluster in a clean, reusable, and production-aligned way.

The goal of this project was not just to create resources, but to design the infrastructure following real-world DevOps practices:

**Remote state management**

Reusability using variables 

Avoiding Terraform drift 

Understanding how EKS and autoscaling actually work 

Respecting cloud-native design principles 

<img width="3420" height="1270" alt="image" src="https://github.com/user-attachments/assets/4a14271c-459b-4ba2-bd2f-6015c61caacc" />


# What This Project Creates

Using Terraform, this setup provisions:

- [x] VPC

- [x] Custom CIDR

- [x] Multiple public subnets across AZs

- [x] Internet Gateway

- [x] Route table and associations

- [x] IAM

- [x] EKS cluster IAM role

- [x] EKS worker node IAM role

- [x] Required AWS managed policy attachments

- [x] EKS

- [x] EKS cluster

- [x] Managed node group with autoscaling

- [x] Configurable instance type and scaling values

- [x] EC2

- [x] Security group with SSH access

- [x] Terraform Backend

- [x] S3 bucket for remote state

- [x] DynamoDB table for state locking
(created separately using a bootstrap approach)

```
# Project Structure
.
├── main.tf            # All infrastructure resources
├── variables.tf       # Input variables
├── terraform.tfvars   # Environment-specific values
├── backend.tf         # Remote state configuration
└── README.md
```


This structure keeps things simple but scalable without introducing modules prematurely.

Key Design Decisions (Important)

1. Remote State Bootstrapping 

S3 bucket and DynamoDB table are not created in this stack

They are created separately using Terraform (bootstrap stack)

This avoids circular dependencies and state issues

Reason: Terraform backend must exist before terraform init.

2. Reusability via Variables 

Hard-coded values were removed and replaced with variables:

Region

CIDRs

Availability Zones

Cluster name

Instance types

Node scaling values

AMI ID

This allows:

Easy reuse across environments

No code changes between dev / stage / prod

3. Use of count 

count is used for subnets and route table associations to:

Avoid duplicate resource blocks

Dynamically create resources based on input lists

Keep the configuration declarative and scalable

4. Tagging Strategy 

Tags are applied consistently across resources

Tags are used for ownership, environment identification, and cost tracking

Resource-specific Name tags are used where human readability matters

5. EKS Worker Node Naming (Important Clarification)

Worker nodes are managed by Auto Scaling Groups

Fixed names like eks-worker1, eks-worker2 are intentionally not used

Nodes are treated as cattle, not pets

Instead: 

EC2 Name tags are used for visibility

Kubernetes labels should be used for scheduling and differentiation

This aligns with how EKS is designed to work in production.

How to Use This Repo
Prerequisites

AWS CLI configured

Terraform installed

Backend S3 bucket and DynamoDB table already created

<img width="3456" height="1258" alt="image" src="https://github.com/user-attachments/assets/b3c56ef6-bc91-4071-b638-e16b2baf36cf" />

<img width="3456" height="1258" alt="image" src="https://github.com/user-attachments/assets/06dc2f39-405e-4346-9bec-dd906ad8b452" />

```
Steps
terraform init
terraform plan
terraform apply
```

To reuse for another environment:

Copy terraform.tfvars

Change values (region, CIDRs, sizes, names)

Apply again

Outputs

After successful apply:

Public IP of EC2 instance

EKS cluster name

<img width="3456" height="994" alt="image" src="https://github.com/user-attachments/assets/2846aed8-dc29-4cec-87b3-f8145e5e5d72" />







