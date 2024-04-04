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

resource "aws_glue_catalog_table" "table" {
  database_name = var.schema
  name          = var.name

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

      location = "s3://${var.bucket}/${var.file-path-prefix}/AWSLogs"

      dynamic "columns" {
        for_each = [
          for column-name in sort(var.columns) : column-name if !var.column-definitions[column-name].synthetic
        ]
        iterator = column-name

        content {
          name = column-name.value
          type = var.column-definitions[column-name.value].hive-physical-type
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
    "projection.partition_utc.range"         = "NOW-${var.history-days}DAY,NOW",
    "projection.partition_utc.interval"      = "1",
    "projection.partition_utc.interval.unit" = "HOURS",

    "storage.location.template" = "s3://${var.bucket}/${var.file-path-prefix}/AWSLogs/$${account_id}/vpcflowlogs/$${region}/$${partition_utc}/"
  }
}
