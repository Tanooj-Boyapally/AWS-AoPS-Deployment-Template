# AWS Profile
variable "aws_profile" {
  description = "AWS profile name"
  type        = string
  default     = ""
}

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

# EBS Volume Configuration
variable "volume_names" {
  description = "List of EBS volume names to create"
  type        = list(string)
  default     = ["mongodb-data"]
}

variable "volume_sizes" {
  description = "List of EBS volume sizes in GB"
  type        = list(number)
  default     = [20]
}

variable "availability_zones" {
  description = "List of availability zones for EBS volumes"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "volume_type" {
  description = "The type of EBS volume. Can be standard, gp2, gp3, io1, io2, sc1, or st1"
  type        = string
  default     = "gp3"
  
  validation {
    condition     = contains(["standard", "gp2", "gp3", "io1", "io2", "sc1", "st1"], var.volume_type)
    error_message = "Volume type must be one of: standard, gp2, gp3, io1, io2, sc1, st1."
  }
}

variable "gp3_iops" {
  description = "The amount of IOPS to provision for gp3 volumes (3000-16000)"
  type        = number
  default     = 3000
  
  validation {
    condition     = var.gp3_iops >= 3000 && var.gp3_iops <= 16000
    error_message = "GP3 IOPS must be between 3000 and 16000."
  }
}

variable "gp3_throughput" {
  description = "The throughput to provision for gp3 volumes in MB/s (125-1000)"
  type        = number
  default     = 125
  
  validation {
    condition     = var.gp3_throughput >= 125 && var.gp3_throughput <= 1000
    error_message = "GP3 throughput must be between 125 and 1000 MB/s."
  }
}

variable "provisioned_iops" {
  description = "The amount of provisioned IOPS for io1/io2 volumes"
  type        = number
  default     = 100
}

# Encryption Configuration
variable "encrypted" {
  description = "If true, the disk will be encrypted"
  type        = bool
  default     = true
}

variable "kms_key_id" {
  description = "The ARN of the AWS KMS key to use for encryption"
  type        = string
  default     = null
}

# Multi-Attach Configuration
variable "multi_attach_enabled" {
  description = "Specifies whether Amazon EBS Multi-Attach is enabled"
  type        = bool
  default     = false
}

# Snapshot Configuration
variable "final_snapshot" {
  description = "If true, snapshot will be created before volume deletion"
  type        = bool
  default     = true
}

variable "create_snapshots" {
  description = "Create initial snapshots of volumes"
  type        = bool
  default     = false
}

# Data Lifecycle Manager (DLM) Configuration
variable "enable_dlm_policy" {
  description = "Enable AWS DLM policy for automated backups"
  type        = bool
  default     = true
}

variable "dlm_target_tags" {
  description = "Target tags for DLM policy"
  type        = map(string)
  default = {
    Environment = "dev"
  }
}

variable "dlm_interval" {
  description = "How often this lifecycle policy should be evaluated"
  type        = number
  default     = 24
}

variable "dlm_interval_unit" {
  description = "The unit for how often the lifecycle policy should be evaluated"
  type        = string
  default     = "HOURS"
  
  validation {
    condition     = contains(["HOURS"], var.dlm_interval_unit)
    error_message = "DLM interval unit must be HOURS."
  }
}

variable "dlm_times" {
  description = "A list of times in 24 hour clock format that sets when the lifecycle policy should be evaluated"
  type        = list(string)
  default     = ["23:45"]
}

variable "dlm_retain_count" {
  description = "How many snapshots to keep"
  type        = number
  default     = 7
}

# Kubernetes Storage Class Configuration (for reference only)
variable "storage_class_name" {
  description = "Name of the Kubernetes StorageClass (create this in K8s)"
  type        = string
  default     = "ebs-csi-gp3"
}

variable "reclaim_policy" {
  description = "Reclaim policy for the StorageClass (Delete or Retain)"
  type        = string
  default     = "Retain"
  
  validation {
    condition     = contains(["Delete", "Retain"], var.reclaim_policy)
    error_message = "Reclaim policy must be either Delete or Retain."
  }
}

variable "volume_binding_mode" {
  description = "Volume binding mode for the StorageClass"
  type        = string
  default     = "WaitForFirstConsumer"
  
  validation {
    condition     = contains(["Immediate", "WaitForFirstConsumer"], var.volume_binding_mode)
    error_message = "Volume binding mode must be either Immediate or WaitForFirstConsumer."
  }
}

variable "allow_volume_expansion" {
  description = "Allow volume expansion for the StorageClass"
  type        = bool
  default     = true
}

variable "fs_type" {
  description = "File system type for the volumes"
  type        = string
  default     = "ext4"
  
  validation {
    condition     = contains(["ext4", "xfs"], var.fs_type)
    error_message = "File system type must be either ext4 or xfs."
  }
}

# CloudWatch Monitoring Configuration
variable "enable_cloudwatch_alarms" {
  description = "Enable CloudWatch alarms for EBS volumes"
  type        = bool
  default     = true
}

variable "burst_balance_threshold" {
  description = "Threshold for burst balance alarm (only for gp2 volumes)"
  type        = number
  default     = 20
}

variable "sns_topic_arn" {
  description = "SNS topic ARN for CloudWatch alarm notifications"
  type        = string
  default     = null
}

# Common Tags
variable "common_tags" {
  description = "Common tags to apply to all EBS resources"
  type        = map(string)
  default = {
    Environment = "dev"
    Project     = "my-project"
    ManagedBy   = "terraform"
  }
}
