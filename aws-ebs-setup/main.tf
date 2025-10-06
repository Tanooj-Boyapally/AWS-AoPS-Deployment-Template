# Configure the AWS Provider
terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  
  # Optional: Use S3 backend for state storage
  # backend "s3" {
  #   bucket = "your-terraform-state-bucket"
  #   key    = "ebs/terraform.tfstate"
  #   region = "us-west-2"
  # }
}

provider "aws" {
  region  = var.region
  profile = var.aws_profile != "" ? var.aws_profile : null
  # Credentials will be automatically sourced from:
  # 1. AWS profile (if specified)
  # 2. Environment variables (AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY)
  # 3. AWS credentials file (~/.aws/credentials)
  # 4. IAM roles (if running on EC2/ECS/Lambda)
  access_key = var.aws_access_key != "" ? var.aws_access_key : null
  secret_key = var.aws_secret_key != "" ? var.aws_secret_key : null
}

# Data source to get available AZs
data "aws_availability_zones" "available" {
  state = "available"
}

# EBS Volumes
resource "aws_ebs_volume" "ebs_volumes" {
  count = length(var.volume_names)
  
  availability_zone = var.availability_zones[count.index % length(var.availability_zones)]
  size              = var.volume_sizes[count.index]
  type              = var.volume_type
  iops              = var.volume_type == "gp3" ? var.gp3_iops : (contains(["io1", "io2"], var.volume_type) ? var.provisioned_iops : null)
  throughput        = var.volume_type == "gp3" ? var.gp3_throughput : null
  
  encrypted  = var.encrypted
  kms_key_id = var.encrypted && var.kms_key_id != null ? var.kms_key_id : null
  
  multi_attach_enabled = var.multi_attach_enabled
  
  final_snapshot = var.final_snapshot

  tags = merge(
    var.common_tags,
    {
      Name = var.volume_names[count.index]
      Size = "${var.volume_sizes[count.index]}GB"
      Type = var.volume_type
    }
  )
}

# EBS Snapshots (if enabled)
resource "aws_ebs_snapshot" "ebs_snapshots" {
  count = var.create_snapshots ? length(var.volume_names) : 0
  
  volume_id   = aws_ebs_volume.ebs_volumes[count.index].id
  description = "Snapshot of ${var.volume_names[count.index]} created by Terraform"
  
  tags = merge(
    var.common_tags,
    {
      Name = "${var.volume_names[count.index]}-snapshot"
      VolumeId = aws_ebs_volume.ebs_volumes[count.index].id
    }
  )
}

# Data Lifecycle Manager (DLM) Policy for automated snapshots
resource "aws_dlm_lifecycle_policy" "ebs_backup_policy" {
  count = var.enable_dlm_policy ? 1 : 0
  
  description        = "EBS backup policy managed by Terraform"
  execution_role_arn = aws_iam_role.dlm_lifecycle_role[0].arn
  state              = "ENABLED"

  policy_details {
    resource_types   = ["VOLUME"]
    target_tags      = var.dlm_target_tags

    schedule {
      name = "Daily snapshots"

      create_rule {
        interval      = var.dlm_interval
        interval_unit = var.dlm_interval_unit
        times         = var.dlm_times
      }

      retain_rule {
        count = var.dlm_retain_count
      }

      copy_tags = true
    }
  }

  tags = merge(
    var.common_tags,
    {
      Name = "ebs-dlm-policy"
    }
  )
}

# IAM Role for DLM
resource "aws_iam_role" "dlm_lifecycle_role" {
  count = var.enable_dlm_policy ? 1 : 0
  
  name = "${var.common_tags.Project}-dlm-lifecycle-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "dlm.amazonaws.com"
        }
      }
    ]
  })

  tags = var.common_tags
}

# IAM Role Policy Attachment for DLM
resource "aws_iam_role_policy_attachment" "dlm_lifecycle_policy" {
  count = var.enable_dlm_policy ? 1 : 0
  
  role       = aws_iam_role.dlm_lifecycle_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSDataLifecycleManagerServiceRole"
}

# Note: Kubernetes StorageClass should be created directly in Kubernetes
# This is just for reference - create this in your K8s cluster instead
# See the mongodb-k8s-manifests.yaml file for the actual StorageClass definition

# CloudWatch Alarms for EBS volumes (optional)
resource "aws_cloudwatch_metric_alarm" "ebs_burst_balance" {
  count = var.enable_cloudwatch_alarms && var.volume_type == "gp2" ? length(var.volume_names) : 0
  
  alarm_name          = "${var.volume_names[count.index]}-burst-balance-low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "BurstBalance"
  namespace           = "AWS/EBS"
  period              = "300"
  statistic           = "Average"
  threshold           = var.burst_balance_threshold
  alarm_description   = "This metric monitors EBS volume burst balance"
  alarm_actions       = var.sns_topic_arn != null ? [var.sns_topic_arn] : []

  dimensions = {
    VolumeId = aws_ebs_volume.ebs_volumes[count.index].id
  }

  tags = var.common_tags
}
