# terraform.tfvars

# AWS Configuration
region = "us-east-1"

# Optional: AWS Credentials (recommended to use AWS CLI or environment variables instead)
# aws_access_key = "your-access-key"
# aws_secret_key = "your-secret-key"

# EKS Cluster Configuration
cluster_name    = "devops-cluster"
cluster_version = "1.32"

# Node Group Configuration
node_instance_types = ["m5.xlarge"]
desired_capacity    = 1
max_capacity        = 4
min_capacity        = 1

# AWS Load Balancer Controller Configuration
alb_controller_version = "1.8.1"

# AWS EBS CSI Driver Configuration
<<<<<<< HEAD
ebs_csi_driver_version = "2.28.0"
=======
ebs_csi_driver_version = "2.28.0"
>>>>>>> 2eb9405 (updated the latest file for eks setup in AWS)
