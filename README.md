# COB

COB is a reusable Terraform-based AWS platform foundation.

The goal of COB is to give engineering teams common AWS infrastructure that follows the same basic standards without every team having to build the infrastructure from scratch.

## Architecture Diagram
<img width="1422" height="1002" alt="architecture" src="https://github.com/user-attachments/assets/edab2c20-e3a5-44b4-a2a0-1b1445e4d431" />



## Capabilities

The first version of COB provides reusable modules for:

* Networking
* Identity and Access
* Object Storage
* EC2
* ECS
* RDS
* AWS Glue Data Catalog
* Amazon Athena

## Platform standards

The modules are designed around a few common standards:

* Consistent resource naming
* Standard resource tags
* Encryption at rest where applicable
* Private networking for workloads that do not need direct internet access
* Secure S3 configuration
* Least-privilege IAM where practical
* Security groups with controlled access
* Environment separation
* Lifecycle and backup settings where appropriate
* Cost-conscious defaults

## Repository structure

```text
terraform-project-cob/
│
├── modules/
│   ├── networking/
│   ├── identity/
│   ├── object-storage/
│   ├── compute/
│   │   ├── ec2/
│   │   └── ecs/
│   ├── database/
│   │   └── rds/
│   └── data-platform/
│
├── examples/
│   └── analytics/
│
├── environments/
│
├── docs/
│
└── README.md
```

## What makes these reusable modules?

For this project, a Terraform module is treated as a reusable capability rather than just a wrapper around one AWS resource.

For example, the object storage module does more than create an S3 bucket. It creates the bucket together with:

* Public access blocking
* Encryption
* Versioning
* Lifecycle management
* Standard naming and tags

The same idea is used for the other capabilities where multiple AWS resources need to work together.

## Example

The `examples/analytics` configuration shows how the different COB capabilities can be used together.

It combines networking, storage, identity, compute, database and data platform services into one example workload.

Before running Terraform, AWS credentials need to be configured for the account being used.

```powershell
terraform init
terraform validate
terraform plan
```

To create the resources:

```powershell
terraform apply
```

## Notes

This is a first version of the platform, so some capabilities are intentionally kept simple.

Future versions could add things such as:

* More configurable networking
* More EC2 options
* Additional ECS deployment options
* Customer-managed KMS keys
* More S3 lifecycle controls
* More database configuration options
* Better environment-specific configuration
* CI/CD validation and testing
