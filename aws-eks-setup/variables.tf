# variables.tf
 
# AWS Credentials (Optional - better to use environment variables or AWS CLI)
variable "aws_access_key" {
  description = "AWS access key"
  type        = string
  default     = ""
  sensitive   = true
}
 
variable "aws_secret_key" {
  description = "AWS secret key"
  type        = string
  default     = ""
  sensitive   = true
}
 
# AWS Region
variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}
 
# EKS Cluster Configuration
variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "devops-cluster"
}
 
variable "cluster_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
  default     = "1.32"
}
 
# Node Group Configuration
variable "node_instance_types" {
  description = "Instance types for the EKS node group"
  type        = list(string)
  default     = ["t3.medium"]
}
 
variable "desired_capacity" {
  description = "Desired number of nodes"
  type        = number
  default     = 1
}
 
variable "max_capacity" {
  description = "Maximum number of nodes"
  type        = number
  default     = 4
}
 
variable "min_capacity" {
  description = "Minimum number of nodes"
  type        = number
  default     = 1
}
 
# AWS Load Balancer Controller Configuration
variable "alb_controller_version" {
  description = "Version of AWS Load Balancer Controller Helm chart"
  type        = string
  default     = "1.8.1"
}

# AWS EBS CSI Driver Configuration
variable "ebs_csi_driver_version" {
  description = "Version of AWS EBS CSI Driver Helm chart"
  type        = string
  default     = "2.28.0"
}
