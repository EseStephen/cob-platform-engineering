# Security Group Design

## Overview

COB uses separate security groups for application and database workloads. Security groups are configured using explicit ingress rules and controlled egress rules.

The default design keeps workloads in private subnets and avoids exposing the database directly to the internet.

## ECS Security Group

The ECS/Fargate service receives its own security group:

`<project>-<environment>-ecs-sg`

Ingress is controlled through the `allowed_ingress_cidr` variable.

By default:

```hcl
allowed_ingress_cidr = []
```

This means the ECS service has no inbound access unless the consumer explicitly provides an approved CIDR block.

The example workload therefore follows a secure-by-default approach.

ECS egress is currently allowed to:

```text
0.0.0.0/0
```

This supports outbound traffic required by the workload, including retrieving container images and communicating with external AWS services.

For production workloads, egress should be further restricted where practical.

## RDS Security Group

The PostgreSQL database receives a separate security group:

`<project>-<environment>-rds-sg`

The database does not allow unrestricted CIDR-based access.

Instead, PostgreSQL port `5432` is permitted only from the ECS security group:

```text
ECS Security Group
        |
        | TCP 5432
        v
RDS Security Group
```

This creates a security-group-to-security-group trust relationship rather than allowing database access from the internet.

## Network Placement

The architecture places ECS tasks and RDS in private subnets.

RDS is explicitly configured as:

```hcl
publicly_accessible = false
```

Private workloads can use the NAT Gateway for required outbound internet connectivity without receiving public IP addresses.

## Security Principles

The COB example follows these principles:

* No public access to the RDS database.
* Database access is limited to the application security group.
* ECS tasks run without public IP addresses.
* ECS ingress is denied by default unless explicitly configured.
* S3 public access is blocked.
* S3 server-side encryption is enabled.
* IAM permissions are explicitly scoped to required actions and resources.
* IAM wildcard actions are rejected by variable validation.
* Standalone `*` resource permissions are rejected by variable validation.

## Production Considerations

The example is intended as a reusable foundation rather than a complete production security baseline.

Production deployments should additionally consider:

* Restricting security-group egress to required destinations.
* Using an Application Load Balancer instead of direct ECS ingress.
* Using AWS WAF where internet-facing workloads require it.
* Enabling stronger RDS deletion protection.
* Using a customer-managed KMS key where required.
* Reviewing IAM permissions periodically.
* Enabling centralized logging and security monitoring.
* Using immutable container image tags or image digests.
* Applying organizational controls such as AWS Organizations SCPs and CloudTrail.
