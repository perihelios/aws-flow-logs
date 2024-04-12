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

resource "local_file" "debug-table-hive-json" {
  for_each = var.debug-dir == "" ? {} : {
    for name, table in local.athena-table-definitions : name => {
      filename = "${var.debug-dir}/${name}.hive.json"
      json = jsonencode({
        columns        = table.hive-columns
        partition_keys = table.hive-partition-keys
      })
    }
  }

  filename        = each.value.filename
  content         = "${each.value.json}\n"
  file_permission = "0664"
}

resource "local_file" "debug-view-trino-sql" {
  for_each = var.debug-dir == "" ? {} : {
    for name, view in local.athena-view-definitions : name => {
      filename = "${var.debug-dir}/${name}.trino.sql"
      sql      = view.trino-view.originalSql
    }
  }

  filename        = each.value.filename
  content         = "${each.value.sql}\n"
  file_permission = "0664"
}

resource "local_file" "debug-view-trino-json" {
  for_each = var.debug-dir == "" ? {} : {
    for name, view in local.athena-view-definitions : name => {
      filename = "${var.debug-dir}/${name}.trino.json"
      json     = jsonencode(view.trino-view)
    }
  }

  filename        = each.value.filename
  content         = "${each.value.json}\n"
  file_permission = "0664"
}

resource "local_file" "debug-view-hive-json" {
  for_each = var.debug-dir == "" ? {} : {
    for name, view in local.athena-view-definitions : name => {
      filename = "${var.debug-dir}/${name}.hive.json"
      json = jsonencode({
        columns        = view.hive-columns
        partition_keys = view.hive-partition-keys
      })
    }
  }

  filename        = each.value.filename
  content         = "${each.value.json}\n"
  file_permission = "0664"
}
