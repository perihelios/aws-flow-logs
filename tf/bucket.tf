####
# Copyright 2024 Perihelios LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
####

resource "aws_s3_bucket" "flow-logs" {
  bucket = var.bucket-name
}

data "aws_iam_policy_document" "flow-logs" {
  statement {
    principals {
      identifiers = ["delivery.logs.amazonaws.com"]
      type        = "Service"
    }

    actions = ["s3:GetBucketAcl"]

    resources = [aws_s3_bucket.flow-logs.arn]

    condition {
      test     = "StringEquals"
      values   = [data.aws_organizations_organization.current.id]
      variable = "aws:SourceOrgId"
    }
  }

  statement {
    principals {
      identifiers = ["delivery.logs.amazonaws.com"]
      type        = "Service"
    }

    actions = ["s3:PutObject"]

    resources = [
      "${aws_s3_bucket.flow-logs.arn}/${var.data-management.tgw.raw-s3-prefix}/AWSLogs/$${aws:SourceAccount}/vpcflowlogs/*",
      "${aws_s3_bucket.flow-logs.arn}/${var.data-management.vpc.raw-s3-prefix}/AWSLogs/$${aws:SourceAccount}/vpcflowlogs/*",
    ]

    condition {
      test     = "StringEquals"
      values   = [data.aws_organizations_organization.current.id]
      variable = "aws:SourceOrgId"
    }
  }

  statement {
    effect = "Deny"

    principals {
      identifiers = ["*"]
      type        = "AWS"
    }

    actions = ["s3:*"]

    resources = [
      aws_s3_bucket.flow-logs.arn,
      "${aws_s3_bucket.flow-logs.arn}/*"
    ]

    condition {
      test     = "Bool"
      values   = ["false"]
      variable = "aws:SecureTransport"
    }
  }
}

resource "aws_s3_bucket_policy" "flow-logs" {
  bucket = aws_s3_bucket.flow-logs.bucket
  policy = data.aws_iam_policy_document.flow-logs.json
}

resource "aws_s3_bucket_lifecycle_configuration" "flow-logs" {
  bucket = aws_s3_bucket.flow-logs.bucket

  rule {
    id     = "AthenaWorkgroupCleanup"
    status = "Enabled"

    filter {
      prefix = "${var.athena-workgroup.s3-prefix}/"
    }

    expiration {
      days = 4
    }

    noncurrent_version_expiration {
      noncurrent_days = 1
    }
  }

  rule {
    id     = "GeneralCleanup"
    status = "Enabled"

    abort_incomplete_multipart_upload {
      days_after_initiation = 1
    }

    expiration {
      expired_object_delete_marker = true
    }
  }

  dynamic "rule" {
    for_each = zipmap(
      slice([for tier in var.data-management.tgw.tiers : tostring(tier.days)], 0, length(var.data-management.tgw.tiers) - 1),
      slice(var.data-management.tgw.tiers, 1, length(var.data-management.tgw.tiers)),
    )

    iterator = tier

    content {
      id     = "RawTgwTier${tier.key}"
      status = "Enabled"

      filter {
        prefix = "${var.data-management.tgw.raw-s3-prefix}/*"
      }

      transition {
        days          = tier.key
        storage_class = tier.value.s3-storage-class
      }
    }
  }

  dynamic "rule" {
    for_each = var.data-management.tgw.delete-after-final-tier ? ["x"] : []

    content {
      id     = "RawTgwDelete${var.data-management.tgw.tiers[length(var.data-management.tgw.tiers) - 1].days}"
      status = "Enabled"

      filter {
        prefix = "${var.data-management.tgw.raw-s3-prefix}/*"
      }

      expiration {
        days = var.data-management.tgw.tiers[length(var.data-management.tgw.tiers) - 1].days
      }
    }
  }

  dynamic "rule" {
    for_each = zipmap(
      slice([for tier in var.data-management.vpc.tiers : tostring(tier.days)], 0, length(var.data-management.vpc.tiers) - 1),
      slice(var.data-management.vpc.tiers, 1, length(var.data-management.vpc.tiers)),
    )

    iterator = tier

    content {
      id     = "RawVpcTier${tier.key}"
      status = "Enabled"

      filter {
        prefix = "${var.data-management.vpc.raw-s3-prefix}/*"
      }

      transition {
        days          = tier.key
        storage_class = tier.value.s3-storage-class
      }
    }
  }

  dynamic "rule" {
    for_each = var.data-management.vpc.delete-after-final-tier ? ["x"] : []

    content {
      id     = "RawVpcDelete${var.data-management.vpc.tiers[length(var.data-management.vpc.tiers) - 1].days}"
      status = "Enabled"

      filter {
        prefix = "${var.data-management.vpc.raw-s3-prefix}/*"
      }

      expiration {
        days = var.data-management.vpc.tiers[length(var.data-management.vpc.tiers) - 1].days
      }
    }
  }
}
