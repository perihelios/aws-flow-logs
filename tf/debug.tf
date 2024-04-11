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

resource "local_file" "debug-view-trino-sql" {
  for_each = var.debug-dir == "" ? {} : {
    for name, resource in aws_glue_catalog_table.view : name => {
      filename = "${var.debug-dir}/${name}.trino.sql"
      sql = jsondecode(
        base64decode(
          replace(
            resource.view_original_text,
            "/^\\/\\*\\s+Presto View:\\s+(.*?)\\s+\\*\\/$/",
            "$1"
          )
        )
      )["originalSql"]
    }
  }

  filename        = each.value.filename
  content         = "${each.value.sql}\n"
  file_permission = "0664"
}

resource "local_file" "debug-view-trino-json" {
  for_each = var.debug-dir == "" ? {} : {
    for name, resource in aws_glue_catalog_table.view : name => {
      filename = "${var.debug-dir}/${name}.trino.json"
      json = base64decode(
        replace(
          resource.view_original_text,
          "/^\\/\\*\\s+Presto View:\\s+(.*?)\\s+\\*\\/$/",
          "$1"
        )
      )
    }
  }

  filename        = each.value.filename
  content         = "${each.value.json}\n"
  file_permission = "0664"
}

resource "local_file" "debug-view-hive-json" {
  for_each = var.debug-dir == "" ? {} : {
    for name, resource in aws_glue_catalog_table.view : name => {
      filename = "${var.debug-dir}/${name}.hive.json"
      json = jsonencode({
        columns = [
          for column in resource.storage_descriptor[0].columns: {
            name = column.name
            type = column.type
            comment = column.comment
          }
        ]
        partition_keys = [
          for column in resource.partition_keys: {
            name = column.name
            type = column.type
            comment = column.comment
          }
        ]
      })
    }
  }

  filename        = each.value.filename
  content         = "${each.value.json}\n"
  file_permission = "0664"
}
