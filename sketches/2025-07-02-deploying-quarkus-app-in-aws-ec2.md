---
title: 'Deploying a Quarkus application into AWS EC2'
categories: [AWS, EC2]
tags: [aws, ec2, rds, linux]
---

For this blogpost, we will be using the application first showed in my previous post **Building a Quarkus CRUD application**.

# Creating a simple infrastructure for our application

Previously, we've tested our Quarkus application locally in our machine, using a Docker container
running a Postgres database to test the CRUD service. Now we will be deploying this application
in AWS so we can see how quickly and easily we can deploy our app in the cloud.

The infrastructure we will be using is very simple:

- An EC2 instance which will run our app (we won't be using ASG or Load Balancers here);
- An RDS database (using Postgres);
- A security group for our EC2 instance, that allows in-bound traffic into the 8080 port (where Quarkus listens by default);
- A security group for our RDS instance, that allows in-bound traffic into the 5432 port (only from sources coming from the EC2 security group);

We could manually create all these resources in AWS Console, but we can just use Terraform to declare all our resource and then
create such resources in our AWS account.

The `main.tf` used is here: [Terraform Quarkus Demo](https://github.com/Lincoln-Yuji/quarkus-backend-employee-service/tree/main/terraform)

**Note:** Before trying to use Terraform, check if you have the `aws` CLI program installed and configured in your system!

Having all properly configured, we can just run:

```sh
$ terraform init
$ terrfaorm validate
$ terraform apply
```

**Note:** you can later delete all these resources created by Terraform by running `terraform destroy`.

# Deploy and run the code in the EC2 instance

**TODO**

# Testing the API using Postman

**TODO**