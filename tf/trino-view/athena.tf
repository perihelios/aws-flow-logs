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

resource "aws_glue_catalog_table" "view" {
  database_name = var.schema
  name          = var.name

  table_type = "VIRTUAL_VIEW"

  # The technique of building Presto (now Trino) views as Glue tables was helpfully described in this StackOverflow
  #  answer: https://stackoverflow.com/a/56347331
  #
  # Thanks to Theo (https://stackoverflow.com/users/1109/theo) for his work reverse-engineering how to do this, since
  #  AWS didn't bother to document it!
  #
  view_original_text = "/* Presto View: ${base64encode(local.json)} */"
  view_expanded_text = "/* Presto View */"

  dynamic "partition_keys" {
    for_each = [for column-name in var.columns: column-name if var.column-definitions[column-name].partition-key]
    iterator = column-name

    content {
      name    = column-name.value
      type    = var.column-definitions[column-name.value].hive-logical-type
      comment = "Type: ${
            var.column-definitions[column-name.value].trino-type
          }${
            var.column-definitions[column-name.value].nullable ? " (nullable)" : ""
          } \u2022 Description: ${
            var.column-definitions[column-name.value].description
          }"
    }
  }

  dynamic "storage_descriptor" {
    for_each = [1] # Single iteration needed for nested dynamic blocks

    content {
      number_of_buckets = 0

      dynamic "columns" {
        for_each = [for column-name in var.columns: column-name if !var.column-definitions[column-name].partition-key]
        iterator = column-name

        content {
          name    = column-name.value
          type    = var.column-definitions[column-name.value].hive-logical-type
          comment = "Type: ${
            var.column-definitions[column-name.value].trino-type
          }${
            var.column-definitions[column-name.value].nullable ? " (nullable)" : ""
          } \u2022 Description: ${
            var.column-definitions[column-name.value].description
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
