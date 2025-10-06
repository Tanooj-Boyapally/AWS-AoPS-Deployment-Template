# AWS Configuration
region = "us-east-1"
aws_profile = "devops"

# Optional: AWS Credentials (recommended to use AWS CLI or environment variables instead)
# aws_access_key = "your-access-key"
# aws_secret_key = "your-secret-key"

# EBS Volume Configuration
volume_names = [
  "mongodb-data-1"
]

# FIX: volume_sizes should match the number of volume_names
volume_sizes = [50]  # Only one volume size for one volume name

availability_zones = [
  "us-east-1b"
]

volume_type = "gp3"

# GP3 Performance Configuration
gp3_iops       = 3000    # IOPS (3000-16000)
gp3_throughput = 125     # MB/s (125-1000)

# For io1/io2 volumes (uncomment if using)
# provisioned_iops = 1000

# Encryption Configuration
encrypted   = true
kms_key_id  = null  # Use default AWS managed key, or specify custom KMS key ARN

# Multi-Attach Configuration (usually false for MongoDB)
multi_attach_enabled = false

# Snapshot Configuration
final_snapshot    = true
create_snapshots  = false

# Data Lifecycle Manager (DLM) Configuration for Automated Backups
enable_dlm_policy = true
dlm_target_tags = {
  Environment = "development"
  Project     = "devops-project"
}
dlm_interval      = 24        # Hours
dlm_interval_unit = "HOURS"
dlm_times         = ["02:00"]  # 2 AM UTC
dlm_retain_count  = 7          # Keep 7 daily snapshots

# Kubernetes Storage Class Configuration (create this in K8s cluster)
storage_class_name     = "ebs-csi-gp3-mongodb"
reclaim_policy         = "Retain"           # Keep PV when PVC is deleted
volume_binding_mode    = "WaitForFirstConsumer"  # Better for multi-AZ clusters
allow_volume_expansion = true
fs_type               = "ext4"

# CloudWatch Monitoring Configuration
enable_cloudwatch_alarms = true
burst_balance_threshold  = 20    # Only applies to gp2 volumes
sns_topic_arn           = null   # Add SNS topic ARN if you want email notifications

# Common Tags
common_tags = {
  Environment = "development"
  Project     = "devops-project"
  Team        = "platform-team"
  ManagedBy   = "terraform"
  Owner       = "devops@company.com"
  Application = "mongodb"
  Backup      = "required"
}
