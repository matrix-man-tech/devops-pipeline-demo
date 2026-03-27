# DevOps Pipeline Demo

A complete DevOps pipeline built from scratch.

## Architecture

- **App**: Node.js + Express REST API
- **Container**: Docker + docker-compose
- **CI/CD**: GitHub Actions (lint → test → build → deploy)
- **IaC**: Terraform (AWS VPC, EC2, S3)
- **Monitoring**: Prometheus + Grafana (see monitoring section)

## Quick Start

### Run locally
```bash
npm install
npm start
# Visit http://localhost:3000
```

### Run with Docker
```bash
docker-compose up
# Visit http://localhost:3000
```

### Terraform (Infrastructure)
```bash
cd terraform
terraform init
terraform plan
terraform apply
```

## CI/CD Pipeline

Every push to `main` triggers:
1. **Lint** — ESLint checks code quality
2. **Test** — Jest runs automated tests
3. **Build** — Docker image is built and verified
4. **Deploy** — App is deployed to production

## Infrastructure (Terraform)

| Resource | Type | Purpose |
|---|---|---|
| VPC | Network | Isolated cloud network |
| Subnet | Network | Public subnet for the app |
| Internet Gateway | Network | Allows internet access |
| Security Group | Firewall | Controls incoming/outgoing traffic |
| EC2 Instance | Compute | Virtual machine running the app |
| S3 Bucket | Storage | Stores artifacts and logs |