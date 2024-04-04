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
      "${aws_s3_bucket.flow-logs.arn}/${var.tgw-log-raw-prefix}/AWSLogs/$${aws:SourceAccount}/vpcflowlogs/*",
      "${aws_s3_bucket.flow-logs.arn}/${var.vpc-log-raw-prefix}/AWSLogs/$${aws:SourceAccount}/vpcflowlogs/*",
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
    id     = "AthenaWorkgroup"
    status = "Enabled"

    filter {
      prefix = "${var.athena-workgroup-prefix}/"
    }

    expiration {
      days = 4
    }

    noncurrent_version_expiration {
      noncurrent_days = 1
    }
  }

  rule {
    id     = "AbandonedMultipartCleanup"
    status = "Enabled"

    abort_incomplete_multipart_upload {
      days_after_initiation = 1
    }
  }
}
