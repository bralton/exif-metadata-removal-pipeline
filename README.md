# EXIF Metadata Removal Pipeline

## Project Overview

This Terraform project implements an automated pipeline that:

1. Monitors S3 Bucket A for new `.jpg` uploads (All variations of the extension)
2. Removes EXIF metadata from uploaded images via lambda function triggered on event bridge
3. Saves sanitized images to S3 Bucket B (preserving file paths)
4. Creates IAM users with appropriate access controls to Buckets A & B

## Architecture

```
┌─────────────┐
│  S3 Bucket A│
│ (Upload)    │
└──────┬──────┘
       │ S3 Event Notification
       ▼
┌─────────────────┐
│ EventBridge Rule│
└──────┬──────────┘
       │ Trigger
       ▼
┌─────────────────┐      ┌──────────────┐
│ Lambda Function │─────▶│  S3 Bucket B │
│ (Remove EXIF)   │      │  (Sanitized) │
└─────────────────┘      └──────────────┘

IAM Users:
- User A: Read/Write → Bucket A
- User B: Read-Only → Bucket B
```

## Project Structure

This project follows a **component-based architecture** with separated state files:

```
terraform-standard-layout/
├── modules/                          # Reusable, environment-agnostic modules
│   ├── s3-bucket/                   # S3 bucket with configurable settings
│   ├── lambda-exif-remover/         # Lambda function infrastructure
│   └── iam-users/                   # IAM user management
│
├── environments/                     # Environment-specific deployments
│   ├── staging/
│   │   ├── common.tfvars            # Shared environment variables
│   │   ├── storage/                 # Component 1: S3 Buckets (separate state)
│   │   ├── exif-pipeline/           # Component 2: Lambda + EventBridge (separate state)
│   │   └── iam/                     # Component 3: IAM Users (separate state)
│   └── production/
│       ├── common.tfvars            # Shared environment variables
│       ├── storage/
│       ├── exif-pipeline/
│       └── iam/
│
├── lambda/                          # Lambda function source code
│   └── exif_remover/
│       ├── lambda_function.py       # EXIF removal logic
│       ├── requirements.txt         # Python dependencies
│       └── build.sh                 # Build script for Lambda deployment package
│
└── README.md
```

Due to the `common.tfvars` file in the root of each environment, it is **important** to pass the `--var-file='../common.tfvars` flag to any `terraform plan` or `terraform apply` commands from inside of the component folders.

## Why Component-Based Structure?

### Benefits

- **Fast Deployments** - Only refresh resources in the component you're changing (~90% faster)
- **Isolated Blast Radius** - Changes in IAM don't affect storage
- **Parallel Execution** - Multiple teams can deploy different components simultaneously
- **Clear Ownership** - Each component has a single responsibility
- **Independent State** - No massive state files that slow down operations

### Component Dependencies

```
storage (foundation)
   ↓
exif-pipeline (depends on storage outputs, read via remote state)

storage (foundation)
   ↓
iam (depends on storage outputs, read via remote state)
```

Components communicate via **Terraform Remote State** data sources:

### Backend Configuration

Each component has its own backend configuration.

### Environment Examples

Split folders for environments. Example shows them running in different regions:

- Staging (eu-west-1)
- Production (eu-west-2)

Ideally these are seperate AWS accounts, and then they could be in the same region to remove region variations.
