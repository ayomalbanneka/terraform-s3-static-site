# S3 Static Site - Terraform
<img width="1158" height="674" alt="Diagram Animation with AWS Icons" src="https://github.com/user-attachments/assets/ce5d5b59-d2c3-4bee-9b6b-ea361a585b6b" />

Deploys a static website to Amazon S3 using a reusable Terraform module. No servers, no containers, just an S3 bucket configured for public static website hosting, with Terraform managing both the infrastructure and the file uploads.

---

## Table of Contents

- [Architecture](#architecture)
- [Design Decisions](#design-decisions)
- [Prerequisites](#prerequisites)
- [Setup](#setup)
- [Updating Site Content](#updating-site-content)
- [Outputs](#outputs)
- [Common Issues](#common-issues)
- [Tearing Down](#tearing-down)
- [Stack](#stack)
- [Roadmap](#roadmap)
- [License](#license)

---

## Architecture

```
s3-static-site/
├── main.tf                     # Root module — wires everything together
├── variables.tf                # Root input variables
├── outputs.tf                  # Root outputs (website URL, bucket name)
├── providers.tf                # Provider + Terraform version constraints
├── terraform.tfvars.example    # Copy to terraform.tfvars and fill in
├── .gitignore                  # Excludes state, secrets, local Terraform files
├── site/                       # Your actual website files (HTML/CSS/JS)
│   ├── index.html
│   └── error.html
└── modules/
    └── s3-static-site/
        ├── main.tf              # Bucket, policy, website config, uploads
        ├── variables.tf
        └── outputs.tf
```

The root module is intentionally thin it just sets variables and calls the child module. All the actual S3 logic (bucket, policy, website config, file uploads) lives in `modules/s3-static-site/`, so it can be reused across multiple sites or environments without duplication.

## Design Decisions

These were deliberate trade-offs for a learning/personal-project setup reconsider them before using this for anything production-facing:

| Decision | Why | Trade-off |
|---|---|---|
| Plain S3 website endpoint (no CloudFront) | Simpler, fewer moving parts, faster to stand up | HTTP only — no HTTPS, no custom domain, no edge caching |
| Local Terraform state | Fine for a single person iterating solo | No locking, no team collaboration, state lives only on your machine |
| Terraform-managed uploads (`aws_s3_object`) | One `apply` handles infra *and* content | Best for small sites with few files; not a substitute for a CI/CD pipeline on larger projects |
| Account-level Block Public Access disabled | Required for the bucket policy to allow public reads | Affects **every** bucket in the AWS account, not just this one |

If you later need HTTPS, a custom domain, or caching, the natural next step is adding a CloudFront distribution with an ACM certificate in front of this bucket.

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/downloads) >= 1.5.0
- An AWS account with credentials configured (`aws configure` or environment variables)
- No AWS Organization SCP blocking public S3 buckets on the account

## Setup

1. Clone the repo and move into it:
   ```bash
   git clone <your-repo-url>
   cd s3-static-site
   ```

2. Copy the example vars file and set your own bucket name (must be globally unique across **all** of AWS, not just your account):
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```
   ```hcl
   # terraform.tfvars
   bucket_name = "your-unique-bucket-name-here"
   aws_region  = "us-east-1"
   environment = "dev"
   ```

3. Add your site content into `site/` — at minimum an `index.html` and `error.html`.

4. Initialize Terraform (downloads the AWS provider):
   ```bash
   terraform init
   ```

5. Review the plan before touching anything:
   ```bash
   terraform plan
   ```

6. Apply:
   ```bash
   terraform apply
   ```

7. Grab your live URL:
   ```bash
   terraform output website_url
   ```

## Updating Site Content

Just edit the files in `site/` and re-run:
```bash
terraform apply
```
Each file's `etag` is derived from its content hash, so Terraform only re-uploads files that actually changed — not the whole directory every time.

Adding a new file type? Make sure its extension is mapped in the `mime_types` local in `modules/s3-static-site/main.tf`, or S3 will serve it as `application/octet-stream` and browsers will prompt a download instead of rendering it.

## Outputs

| Output | Description |
|---|---|
| `website_url` | Full `http://` URL of the live site |
| `bucket_name` | The S3 bucket name |
| `bucket_arn` (module-level) | ARN of the bucket, useful if wiring in other resources later |

## Common Issues

| Error | Cause | Fix |
|---|---|---|
| `BucketAlreadyExists` | Bucket names are global across all AWS accounts, not just yours | Pick a more unique `bucket_name` |
| `AccessDenied ... BlockPublicPolicy` | Account-level S3 Block Public Access overrides bucket-level settings | Handled by `aws_s3_account_public_access_block` in root `main.tf` — make sure the module has `depends_on` it |
| Files download instead of render | Missing or incorrect `Content-Type` | Check the `mime_types` map in the module covers that file's extension |
| `403 Forbidden` on the live URL | Public access block not fully applied, or an Organization SCP restricts public buckets | Re-check the public access block resources; ask an AWS admin about SCPs if applicable |

## Tearing Down

```bash
terraform destroy
```
Removes the bucket, its policy, website configuration, and every uploaded object. The account-level public access block setting is also reverted.

## Stack

- **Terraform** `~> 1.5`
- **AWS Provider** `~> 5.0`
- **AWS S3** — static website hosting, no compute involved

## Roadmap

Ideas for extending this beyond a learning project:

- [ ] CloudFront distribution + ACM certificate for HTTPS and a custom domain
- [ ] Remote state backend (S3 + DynamoDB lock) for team use
- [ ] CI/CD pipeline (GitHub Actions) to run `terraform plan`/`apply` on push
- [ ] Cache invalidation step for CloudFront on content updates
- [ ] Separate `dev`/`prod` environments via `environments/*.tfvars`

## License

MIT - use freely, adapt as needed.
