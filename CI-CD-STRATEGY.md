# Part B: CI/CD Implementation

## Pipeline Workflow

Implement a pipeline following a branch based deployment structure with staging and main for respective staging and prod environments. Access tokens stored in secrets for the different environments and utilised in the pipelines. Assumption made of github so using github actions, but there is no real reason this couldn't be done in any other provider (bitbucket, jenkins, circleci, teamcity etc.).

### Staging Branch Workflow

- **PR to staging**:
  - Terraform plan (output and stored for apply in next step)
  - security scans (tfsec, Checkov + scan lambda dependancies)
- **Merge to staging**:
  - Apply staging environment in dependency order:
  1. Storage (must run first)
  2. IAM and Lambda components (can run in parallel)

### Production Branch Workflow

Same as staging but main branch instead.

## Pipeline Diagram

```mermaid
graph TD
    A[Code Change] --> B{Branch?}

    B -->|PR to staging| C[Staging Plan & Scan]
    B -->|PR to main| D[Production Plan & Scan]

    C --> C1[Terraform Plan - All Components]
    C --> C2[Security Scan - tfsec]
    C --> C3[Security Scan - Checkov]
    C --> C4[Scan Lambda Dependencies]

    D --> D1[Terraform Plan - All Components]
    D --> D2[Security Scan - tfsec]
    D --> D3[Security Scan - Checkov]
    D --> D4[Scan Lambda Dependencies]

    C1 & C2 & C3 & C4 --> E{Merge to staging?}
    D1 & D2 & D3 & D4 --> F{Merge to main?}

    E -->|Yes| G[Apply Staging Storage]
    F -->|Yes| H[Apply Production Storage]

    G --> I[Apply Staging IAM & Lambda in Parallel]
    H --> J[Apply Production IAM & Lambda in Parallel]

    I --> K[Staging Deployed]
    J --> L[Production Deployed]
```
