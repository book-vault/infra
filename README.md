# 🏗️ Book Vault Infrastructure

This repository contains the Infrastructure as Code (IaC) for the Book Vault project, utilizing Terraform and AWS CloudFormation.

## 📋 Overview

```mermaid
graph TB
    subgraph "Infrastructure Components"
        direction TB
        CFT["CloudFormation Templates"]
        TF["Terraform Code"]
        
        subgraph "AWS Resources"
            VPC["VPC & Networking"]
            EC2["EC2 with K3s"]
            S3["State Backend S3"]
            DDB["State Lock DynamoDB"]
            IAM["IAM Roles & OIDC"]
        end
    end
    
    CFT -->|Creates| S3
    CFT -->|Creates| DDB
    CFT -->|Creates| IAM
    TF -->|Provisions| VPC
    TF -->|Deploys| EC2
```

## 🏛️ Repository Structure

```
infra/
├── .github/
│   └── workflows/
│       └── TERRAFORM.yaml
├── aws/
│   ├── keyPair.yaml         # CloudFormation template for SSH key pair
│   └── terraform.yaml       # CloudFormation template for backend resources
└── terraform/
    ├── main.tf              # Main Terraform configuration
    ├── vpc.tf               # vpc and networking resources
    ├── ec2.tf               # ec2 with k3s installed
    └── variables.tf         # Main Terraform configuration
```

## 🔄 GitOps Workflow

```mermaid
flowchart TB
    subgraph "GitHub Actions Workflow"
        A[Trigger Deploy] -->|Authenticate| B[AWS Credentials]
        B -->|Initialize| C[Terraform Setup]
        C -->|Configure| D[Workspace Setup]
        D -->|Execute| E[Infrastructure Changes]
    end

    subgraph "AWS Account"
        F[OIDC Provider]
        G[IAM Role]
        H[S3 Backend]
        I[DynamoDB Lock]
    end

    B -->|Assume Role| G
    F -->|Trust| G
    E -->|State| H
    E -->|Locking| I
```

## 🌐 Network Architecture

```mermaid
graph TB
    subgraph "VPC 10.0.0.0/16"
        direction TB
        IGW[Internet Gateway]
        
        subgraph "Public Subnet A 10.0.1.0/24"
            EC2A[K3s Server]
        end
        
        subgraph "Public Subnet B 10.0.4.0/24"
            FUTURE[Future Use]
        end
        
        RT[Route Table]
    end
    
    INTERNET[Internet] -->|0.0.0.0/0| IGW
    IGW --> RT
    RT --> EC2A
    RT --> FUTURE
```

## 🔒 Security Groups

```mermaid
flowchart LR
    subgraph "Security Group Rules"
        direction TB
        INBOUND["Inbound Rules"]
        OUTBOUND["Outbound Rules"]
    end
    
    INBOUND -->|"TCP 22"| SSH[SSH Access]
    INBOUND -->|"TCP 80"| HTTP[HTTP]
    INBOUND -->|"TCP 443"| HTTPS[HTTPS]
    INBOUND -->|"TCP 6443"| K8S[Kubernetes API]
    OUTBOUND -->|"All Traffic"| ANY[0.0.0.0/0]
```

## 🚀 Deployment Process

```mermaid
sequenceDiagram
    participant GH as GitHub Actions
    participant CFN as CloudFormation
    participant TF as Terraform
    participant AWS as AWS Resources
    
    GH->>CFN: Deploy State Backend
    CFN->>AWS: Create S3 & DynamoDB
    CFN->>AWS: Setup OIDC & IAM Role
    GH->>TF: Initialize Backend
    GH->>TF: Select/Create Workspace
    TF->>AWS: Create VPC & Subnets
    TF->>AWS: Deploy EC2 Instance
    TF->>AWS: Configure Security Groups
```

## 🏷️ Resource Naming Convention

All resources follow the naming pattern: `{environment}-{project}-{service}-{resource}`

Example:
- Environment: `main`
- Project: `bookvault`
- Service: `terraform`
- Resource: `vpc`

Final name: `main-bookvault-terraform-vpc`

## 🔐 AWS Resource Details

1. **VPC Configuration**
   - CIDR: 10.0.0.0/16
   - Public Subnet A: 10.0.1.0/24 (us-east-2a)
   - Public Subnet B: 10.0.4.0/24 (us-east-2b)
   - Internet Gateway for public access

2. **EC2 Instance**
   - Type: t2.medium
   - AMI: Ubuntu
   - K3s installation via user data
   - Public IP association enabled

3. **Security Group Rules**
   - Inbound: SSH (22), HTTP (80), HTTPS (443), Kubernetes API (6443)
   - Outbound: All traffic allowed

## 📦 State Management

CloudFormation creates and manages:
- S3 bucket for Terraform state
- DynamoDB table for state locking
- OIDC provider for GitHub Actions
- IAM roles for GitHub Actions authentication

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.