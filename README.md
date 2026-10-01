# CV AWS Terraform

Terraform project that provisions the AWS infrastructure needed to run the CV application from the [`cv-platform`](https://github.com/ZubiOps/cv-platform) repository.

This is a practical DevOps/IaC project built using the AWS Playground provided by KodeKloud.

## Architecture

```text
cv-platform
    │
    │ Docker + Docker Compose
    │
    ▼
cv-awsterra
    │
    │ Terraform
    ▼
AWS EC2
    │
    │ user_data
    ▼
Docker + Docker Compose
    │
    ▼
CV application :8090
```

`cv-awsterra` is responsible for the AWS infrastructure.

`cv-platform` contains the application and its Docker Compose configuration.

## What Terraform creates

Terraform creates:

* An EC2 instance running Amazon Linux 2023
* A security group allowing public access to port `8090`
* A public IP address for the EC2 instance

The EC2 instance uses `user_data` to automatically:

1. Update the system
2. Install Docker and Git
3. Start Docker
4. Install Docker Compose
5. Clone `cv-platform`
6. Start the application with Docker Compose

## Requirements

* AWS account with permission to create EC2 resources
* Terraform
* Git

This project was tested using the KodeKloud AWS Playground.

The Playground may have restrictions on which EC2 instance types are available in particular Availability Zones.

## Usage

Clone the repository:

```bash
git clone https://github.com/ZubiOps/cv-awsterra.git
cd cv-awsterra
```

Initialise Terraform:

```bash
terraform init
```

Review the infrastructure that will be created:

```bash
terraform plan
```

Create the infrastructure:

```bash
terraform apply
```

Confirm with `yes` when prompted.

## Accessing the application

Terraform outputs the public IP and application URL:

```bash
terraform output
```

Example:

```text
cv_public_ip = "3.x.x.x"
cv_url = "http://3.x.x.x:8090"
```

The application can then be tested with:

```bash
curl http://<PUBLIC_IP>:8090
```

or by opening the `cv_url` output in a browser.

The EC2 public IP can change when the instance is destroyed and recreated.

## Destroying the infrastructure

When finished with the Playground:

```bash
terraform destroy
```

This removes the resources created by Terraform.

## Project relationship

This project is intentionally separated from `cv-platform`.

* **cv-platform** — application, Dockerfile and Docker Compose
* **cv-awsterra** — AWS infrastructure and provisioning with Terraform

The separation makes it possible to change the infrastructure without changing the application itself.

## Future work

The next planned stage is to move the application from EC2/Docker Compose towards Kubernetes on AWS.

EKS is currently deferred because the KodeKloud AWS Playground has IAM restrictions that prevent the required EKS `iam:PassRole` permissions.
