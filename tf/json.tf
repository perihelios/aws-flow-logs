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

locals {
  trino-view-json = {
    tgw = jsonencode({
      originalSql = local.sql.tgw,
      catalog = "awsdatacatalog",
      schema  = var.schema,
      columns = [
        for column-name in var.tgw-columns : {
          name = column-name
          type = local.tgw-column-definitions[column-name].trino-type
        }
      ],
      owner          = data.aws_caller_identity.current.account_id,
      runAsInvoker   = false,
      properties     = {},
      isProtected    = false,
      isMultiDialect = false
    })

    vpc = jsonencode({
      originalSql = local.sql.vpc,
      catalog = "awsdatacatalog",
      schema  = var.schema,
      columns = [
        for column-name in var.vpc-columns : {
          name = column-name
          type = local.vpc-column-definitions[column-name].trino-type
        }
      ],
      owner          = data.aws_caller_identity.current.account_id,
      runAsInvoker   = false,
      properties     = {},
      isProtected    = false,
      isMultiDialect = false
    })
  }

  sql-projections = {
    tgw = [
      for column-name in var.tgw-columns : trimspace(
        replace(
          local.tgw-column-definitions[column-name].trino-projection,
          "/(?m)^${regex("^\\s*", local.tgw-column-definitions[column-name].trino-projection)}/",
          "  "
        )
      )
    ]

    vpc = [
      for column-name in var.vpc-columns : trimspace(
        replace(
          local.vpc-column-definitions[column-name].trino-projection,
          "/(?m)^${regex("^\\s*", local.vpc-column-definitions[column-name].trino-projection)}/",
          "  "
        )
      )
    ]
  }

  sql = {
    tgw = "select\n  ${join(",\n  ", local.sql-projections.tgw)}\nfrom \"${var.schema}\".\"${var.tgw-table-name}\""
    vpc = "select\n  ${join(",\n  ", local.sql-projections.vpc)}\nfrom \"${var.schema}\".\"${var.vpc-table-name}\""
  }
}
