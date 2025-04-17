# TERRAFORM-PROJECT
Built a simple project using Terraform,


INFRASTRUCTURE:

VPC----
 VPC is a  basic foundation for the infrastructure for the project.

SUBNET----
 Using the VPC, created two subnets assigned CIDR block without any overlap.

INSTANCE----
 For each subnet one instance has been launched with the security group rules 

S3----
 To store the objects and data S3 is created.

SECURITY GROUPS---
  In the security group, 
  For Inbound rules to allow:
  SSH port(22) from anywhere to allow remote access to your EC2 instances from any IP address using PuTTY or terminal.
  For Outbound rules allowed to all traffic destinations.
