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

resource "aws_glue_catalog_table" "table" {
  for_each = {
    tgw = {
      name               = var.tgw-table-name
      column-definitions = local.tgw-column-definitions
      columns            = var.tgw-columns
      history-days       = var.data-management.tgw.tiers[length(var.data-management.tgw.tiers) - 1].days
      s3-prefix          = var.data-management.tgw.raw-s3-prefix
    }

    vpc = {
      name               = var.vpc-table-name
      column-definitions = local.vpc-column-definitions
      columns            = var.vpc-columns
      history-days       = var.data-management.vpc.tiers[length(var.data-management.vpc.tiers) - 1].days
      s3-prefix          = var.data-management.vpc.raw-s3-prefix
    }
  }

  database_name = var.schema
  name          = each.value.name

  table_type = "EXTERNAL_TABLE"
  owner      = "hadoop"

  partition_keys {
    name = "account_id"
    type = "string"
  }

  partition_keys {
    name = "region"
    type = "string"
  }

  partition_keys {
    name = "partition_utc"
    type = "string"
  }

  dynamic "storage_descriptor" {
    for_each = [1] # Single iteration needed for nested dynamic blocks

    content {
      input_format  = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetInputFormat"
      output_format = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetOutputFormat"

      number_of_buckets = -1

      location = "s3://${aws_s3_bucket.flow-logs.bucket}/${each.value.s3-prefix}/AWSLogs"

      dynamic "columns" {
        for_each = [
          for column-name in sort(each.value.columns) : column-name
          if !each.value.column-definitions[column-name].synthetic
        ]
        iterator = column-name

        content {
          name = column-name.value
          type = each.value.column-definitions[column-name.value].hive-physical-type
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
    "projection.partition_utc.range"         = "NOW-${each.value.history-days}DAY,NOW",
    "projection.partition_utc.interval"      = "1",
    "projection.partition_utc.interval.unit" = "HOURS",

    "storage.location.template" = "s3://${aws_s3_bucket.flow-logs.bucket}/${each.value.s3-prefix}/AWSLogs/$${account_id}/vpcflowlogs/$${region}/$${partition_utc}/"
  }
}

resource "aws_glue_catalog_table" "view" {
  for_each = merge(
    {
      for tier in var.data-management.tgw.tiers : tier.view-name => {
        source-name = var.tgw-table-name

        column-definitions = local.tgw-column-definitions
        columns            = var.tgw-columns

        trino-definition = merge(local.tgw-trino-view-definition, {
          originalSql = "${local.tgw-base-sql}\nwhere partition_utc > date_format(now() - interval '${tier.days}' day, '%Y/%m/%d/%H')"
        })

        history-days = tier.days
      } if tier.view-name != null
    },
    {
      for tier in var.data-management.vpc.tiers : tier.view-name => {
        source-name = var.vpc-table-name

        column-definitions = local.vpc-column-definitions
        columns            = var.vpc-columns

        trino-definition = merge(local.vpc-trino-view-definition, {
          originalSql = "${local.vpc-base-sql}\nwhere partition_utc > date_format(now() - interval '${tier.days}' day, '%Y/%m/%d/%H')"
        })

        history-days = tier.days
      } if tier.view-name != null
  })

  database_name = var.schema
  name          = each.key

  table_type = "VIRTUAL_VIEW"

  # The technique of building Presto (now Trino) views as Glue tables was helpfully described in this StackOverflow
  #  answer: https://stackoverflow.com/a/56347331
  #
  # Thanks to Theo (https://stackoverflow.com/users/1109/theo) for his work reverse-engineering how to do this, since
  #  AWS didn't bother to document it!
  #
  view_original_text = "/* Presto View: ${base64encode(jsonencode(each.value.trino-definition))} */"
  view_expanded_text = "/* Presto View */"

  dynamic "partition_keys" {
    for_each = [
      for column-name in each.value.columns : column-name
      if each.value.column-definitions[column-name].partition-key
    ]
    iterator = column-name

    content {
      name = column-name.value
      type = each.value.column-definitions[column-name.value].hive-logical-type
      comment = "Type: ${
        each.value.column-definitions[column-name.value].trino-type
        }${
        each.value.column-definitions[column-name.value].nullable ? " (nullable)" : ""
        } \u2022 Description: ${
        each.value.column-definitions[column-name.value].description
      }"
    }
  }

  dynamic "storage_descriptor" {
    for_each = ["x"] # Single iteration needed for nested dynamic blocks

    content {
      number_of_buckets = 0

      dynamic "columns" {
        for_each = [
          for column-name in each.value.columns : column-name
          if !each.value.column-definitions[column-name].partition-key
        ]
        iterator = column-name

        content {
          name = column-name.value
          type = each.value.column-definitions[column-name.value].hive-logical-type
          comment = "Type: ${
            each.value.column-definitions[column-name.value].trino-type
            }${
            each.value.column-definitions[column-name.value].nullable ? " (nullable)" : ""
            } \u2022 Description: ${
            each.value.column-definitions[column-name.value].description
          }"
        }
      }
    }
  }

  parameters = {
    presto_view = "true"
    comment     = "Presto View"
  }
}
