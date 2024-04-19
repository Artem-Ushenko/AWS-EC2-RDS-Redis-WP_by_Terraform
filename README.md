[![CI Apply Terraform Infrastructure](https://github.com/Artem-Ushenko/abz_test_assignment/actions/workflows/on_push_apply_tf.yml/badge.svg)](https://github.com/Artem-Ushenko/abz_test_assignment/actions/workflows/on_push_apply_tf.yml)
# Deploying Elastic Cache Redis & RDS MySQL & EC2 for Wordpress on AWS using Terraform

## Project Description:

#### This repository contains Terraform scripts designed to provision a complete AWS infrastructure optimized for a WordPress web application and script to automate WordPress configuration on server. 

The infrastructure includes the following AWS resources configured within a dedicated Virtual Private Cloud (VPC):

- Amazon EC2 Instance: Serves as the host for the WordPress application, offering scalable compute capacity.
- Amazon RDS (MySQL Instance): Provides a managed relational database service for WordPress data storage, ensuring durability and high availability.
- Amazon ElastiCache (Redis): Utilized for caching database queries and objects, significantly improving the performance and responsiveness of the WordPress site.
- AWS VPC Configuration: Ensures all resources are secured and isolated in a virtual network, tailor-made for this application.

The project aims to demonstrate advanced DevOps competencies by automating the deployment and management of cloud resources, thereby simplifying the scalability and maintenance of web applications on AWS.

## Key Features

### Automated Infrastructure Deployment

- **Terraform Integration**: Utilize Terraform to automate the provisioning of AWS resources, enabling quick and repeatable deployments.
- **Scalability**: Design the architecture to be easily scalable, allowing additional resources to be added with minimal effort as the application demands grow.
- **Security**: Configure security groups and network access control lists within the VPC to safeguard the application and its data.

### Performance and Reliability

- **High Availability**: Set up the Amazon RDS instance to operate in a multi-AZ configuration for enhanced availability and data durability.
- **Performance Optimization**: Implement Redis caching via Amazon ElastiCache to reduce load times and enhance user experience.
- **Load Balancing**: Option to integrate AWS Elastic Load Balancing to distribute incoming traffic across multiple EC2 instances, ensuring even load distribution and increased fault tolerance.

## Installation and Setup

### Prerequisites

- AWS Account: Ensure you have an active AWS account with the necessary permissions to create and manage resources.
- Terraform Installed: You need to have Terraform installed on your local machine or CI/CD environment.
- AWS CLI: Install and configure AWS CLI with appropriate credentials.

### Configuration from local machine

1. **Clone the Repository**: Start by cloning this repository to your local machine or directly to your cloud environment.
   ```
   git clone https://github.com/Artem-Ushenko/AWS-EC2-RDS-Redis-WP_by_Terraform.git
   ```
2. **Initialize Terraform**: Navigate to the cloned Terraform directory and run the following command to initialize Terraform and download required providers.
   ```
   cd terraform
   terraform init
   ```
3. **Configure Variables**: Modify the `terraform.tfvars` or equivalent file to suit your AWS settings, database configurations, and other preferences.
4. **Plan Deployment**: Execute the following command to review the planned infrastructure deployment.
   ```
   terraform plan
   ```
5. **Apply Configuration**: Deploy your infrastructure by running:
   ```
   terraform apply
   ```
6. **Configure AWS on EC2**: Install AWS CLI and configure it with Access Key and Access Secret Key:
   ```
   sudo apt update
   sudo apt install awscli
   aws configure
   ```
7. **Configure WordPress**:Launch BASH script on EC2 to configure WordPress installation:
   ```
   git clone https://github.com/Artem-Ushenko/AWS-EC2-RDS-Redis-WP_by_Terraform.git
   cd script
   chmod 700 script.sh
   sudo -E ./script.sh
   ```
## Usage

Once the infrastructure is deployed, you can access your WordPress site through the public DNS address on port 80 of the EC2 instance. Follow the on-screen instructions to complete the WordPress installation and setup.

## Customization

- **Modify Terraform Scripts**: Adjust the Terraform scripts to add more EC2 instances, change the RDS instance size, or alter the Redis configuration according to your needs.
- **Update Security Settings**: Review and update the security settings periodically to keep up with AWS best practices and emerging threats.

## Contributing

Contributions to this project are welcome! Please consider the following ways to contribute:

- **Bug Reports**: Submit issues for any bugs encountered.
- **Feature Requests**: Suggest new features or enhancements.
- **Pull Requests**: Open pull requests with improvements to the code or documentation. Make sure to adhere to the project's style and contribution guidelines.

## License

This project is licensed under the [MIT License](LICENSE). Full license text is available in the LICENSE file.
