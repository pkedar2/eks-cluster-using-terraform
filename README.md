## Terraform EKS Infrastructure Setup
Overview

This repository contains a Terraform-based setup to provision AWS infrastructure and an EKS cluster in a clean, reusable, and production-aligned way.

The goal of this project was not just to create resources, but to design the infrastructure following real-world DevOps practices:

Remote state management

Reusability using variables

Avoiding Terraform drift

Understanding how EKS and autoscaling actually work

Respecting cloud-native design principles

What This Project Creates

Using Terraform, this setup provisions:

VPC

Custom CIDR

Multiple public subnets across AZs

Internet Gateway

Route table and associations

IAM

EKS cluster IAM role

EKS worker node IAM role

Required AWS managed policy attachments

EKS

EKS cluster

Managed node group with autoscaling

Configurable instance type and scaling values

EC2

Standalone EC2 instance (for testing / access / tooling)

Security group with SSH access

Terraform Backend

S3 bucket for remote state

DynamoDB table for state locking
(created separately using a bootstrap approach)

Project Structure
.
├── main.tf            # All infrastructure resources
├── variables.tf       # Input variables
├── terraform.tfvars   # Environment-specific values
├── backend.tf         # Remote state configuration
└── README.md


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

Steps
terraform init
terraform plan
terraform apply


To reuse for another environment:

Copy terraform.tfvars

Change values (region, CIDRs, sizes, names)

Apply again

Outputs

After successful apply:

Public IP of EC2 instance

EKS cluster name
