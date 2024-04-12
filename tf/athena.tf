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

resource "aws_athena_workgroup" "flow-logs" {
  name        = var.athena-workgroup.name
  description = "Query VPC and TGW flow logs"

  force_destroy = true
  state         = "ENABLED"

  configuration {
    result_configuration {
      expected_bucket_owner = data.aws_caller_identity.current.account_id
      output_location       = "s3://${aws_s3_bucket.flow-logs.bucket}/${var.athena-workgroup.s3-prefix}/"

      acl_configuration {
        s3_acl_option = "BUCKET_OWNER_FULL_CONTROL"
      }
    }
  }
}

resource "aws_glue_catalog_database" "flow-logs" {
  name        = var.schema
  description = "VPC and TGW flow logs"
}

resource "aws_glue_catalog_table" "table" {
  for_each = local.athena-table-definitions

  database_name = aws_glue_catalog_database.flow-logs.name
  name          = each.key

  table_type = "EXTERNAL_TABLE"
  owner      = "hadoop"

  dynamic "partition_keys" {
    for_each = each.value.hive-partition-keys
    iterator = partition-key

    content {
      name = partition-key.value.name
      type = partition-key.value.type
    }
  }

  dynamic "storage_descriptor" {
    for_each = ["x"] # Nested dynamic block "columns" requires outer dynamic block with single iteration

    content {
      input_format  = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetInputFormat"
      output_format = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetOutputFormat"

      number_of_buckets = -1

      location = "s3://${aws_s3_bucket.flow-logs.bucket}/${each.value.s3-prefix}/AWSLogs"

      dynamic "columns" {
        for_each = each.value.hive-columns
        iterator = column

        content {
          name = column.value.name
          type = column.value.type
        }
      }

      ser_de_info {
        parameters = {
          "serialization.format" = "1"
        }
        serialization_library = "org.apache.hadoop.hive.ql.io.parquet.serde.ParquetHiveSerDe"
      }
    }
  }

  parameters = {
    "EXTERNAL" = "TRUE",

    "projection.enabled" = "true",

    "projection.account_id.type" = "injected",

    "projection.region.type" = "injected",

    "projection.partition_utc.type"          = "date",
    "projection.partition_utc.format"        = "yyyy/MM/dd/HH",
    "projection.partition_utc.range"         = "NOW-${each.value.days}DAY,NOW",
    "projection.partition_utc.interval"      = "1",
    "projection.partition_utc.interval.unit" = "HOURS",

    "storage.location.template" = "s3://${aws_s3_bucket.flow-logs.bucket}/${each.value.s3-prefix}/AWSLogs/$${account_id}/vpcflowlogs/$${region}/$${partition_utc}/"
  }
}

resource "aws_glue_catalog_table" "view" {
  for_each = local.athena-view-definitions

  database_name = aws_glue_catalog_database.flow-logs.name
  name          = each.key

  table_type = "VIRTUAL_VIEW"

  # The technique of building Presto (now Trino) views as Glue tables was helpfully described in this StackOverflow
  #  answer: https://stackoverflow.com/a/56347331
  #
  # Thanks to Theo (https://stackoverflow.com/users/1109/theo) for his work reverse-engineering how to do this, since
  #  AWS didn't bother to document it!
  #
  view_original_text = "/* Presto View: ${base64encode(jsonencode(each.value.trino-view))} */"
  view_expanded_text = "/* Presto View */"

  dynamic "partition_keys" {
    for_each = each.value.hive-partition-keys
    iterator = partition-key

    content {
      name    = partition-key.value.name
      type    = partition-key.value.type
      comment = partition-key.value.comment
    }
  }

  dynamic "storage_descriptor" {
    for_each = ["x"] # Nested dynamic block "columns" requires outer dynamic block with single iteration

    content {
      number_of_buckets = 0

      dynamic "columns" {
        for_each = each.value.hive-columns
        iterator = column

        content {
          name    = column.value.name
          type    = column.value.type
          comment = column.value.comment
        }
      }
    }
  }

  parameters = {
    presto_view = "true"
    comment     = "Presto View"
  }
}

locals {
  athena-table-definitions = {
    (var.tgw-table-name) = {
      hive-columns = [
        for column in var.tgw-columns : {
          name = column
          type = local.tgw-column-definitions[column].hive-physical-type
        } if !local.tgw-column-definitions[column].synthetic
      ]

      hive-partition-keys = [
        for column in var.tgw-columns : {
          name = column
          type = local.tgw-column-definitions[column].hive-physical-type
        } if local.tgw-column-definitions[column].partition-key
      ]

      days      = var.data-management.tgw.tiers[length(var.data-management.tgw.tiers) - 1].days
      s3-prefix = var.data-management.tgw.raw-s3-prefix
    }

    (var.vpc-table-name) = {
      hive-columns = [
        for column in var.vpc-columns : {
          name = column
          type = local.vpc-column-definitions[column].hive-physical-type
        } if !local.vpc-column-definitions[column].synthetic
      ]

      hive-partition-keys = [
        for column in var.vpc-columns : {
          name = column
          type = local.vpc-column-definitions[column].hive-physical-type
        } if local.vpc-column-definitions[column].partition-key
      ]

      days      = var.data-management.vpc.tiers[length(var.data-management.vpc.tiers) - 1].days
      s3-prefix = var.data-management.vpc.raw-s3-prefix
    }
  }

  athena-view-definitions = merge(
    {
      for tier in var.data-management.tgw.tiers : tier.view-name => {
        hive-columns        = local.tgw-hive-columns
        hive-partition-keys = local.tgw-hive-partition-keys
        trino-view = merge(local.tgw-trino-view-definition, {
          originalSql = "${local.tgw-base-sql}\n${local.tier-where-clauses[tier.days]}"
        })
      } if tier.view-name != null
    },
    {
      for tier in var.data-management.vpc.tiers : tier.view-name => {
        hive-columns        = local.vpc-hive-columns
        hive-partition-keys = local.vpc-hive-partition-keys
        trino-view = merge(local.vpc-trino-view-definition, {
          originalSql = "${local.vpc-base-sql}\n${local.tier-where-clauses[tier.days]}"
        })
      } if tier.view-name != null
    },
  )

  tier-where-clauses = {
    for days in distinct(concat(var.data-management.tgw.tiers[*].days, var.data-management.vpc.tiers[*].days)) :
    days => "where partition_utc > date_format(at_timezone(now(), 'UTC') - interval '${days}' day, '%Y/%m/%d/%H')"
  }
}
