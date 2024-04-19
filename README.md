[![CI Apply Terraform Infrastructure](https://github.com/Artem-Ushenko/abz_test_assignment/actions/workflows/on_push_apply_tf.yml/badge.svg)](https://github.com/Artem-Ushenko/abz_test_assignment/actions/workflows/on_push_apply_tf.yml)
# Deploying Elastic Cache Redis & RDS MySQL & EC2 for Wordpress on AWS using Terraform

## Project Description:

#### This repository contains Terraform scripts designed to provision a complete AWS infrastructure optimized for a WordPress web application. The infrastructure includes the following AWS resources configured within a dedicated Virtual Private Cloud (VPC):

- Amazon EC2 Instance: Serves as the host for the WordPress application, offering scalable compute capacity.
- Bash Scripting: automate WordPress configuration by Bash script
- Amazon RDS (MySQL Instance): Provides a managed relational database service for WordPress data storage, ensuring durability and high availability.
- Amazon ElastiCache (Redis): Utilized for caching database queries and objects, significantly improving the performance and responsiveness of the WordPress site.
- AWS VPC Configuration: Ensures all resources are secured and isolated in a virtual network, tailor-made for this application.

The project aims to demonstrate advanced DevOps competencies by automating the deployment and management of cloud resources, thereby simplifying the scalability and maintenance of web applications on AWS.
