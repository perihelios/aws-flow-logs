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

module "table-tgw" {
  source = "./flow-log-table"

  schema = var.schema
  name   = var.tgw-table_name

  bucket           = aws_s3_bucket.flow-logs.bucket
  file-path-prefix = var.tgw-log-raw-prefix

  history-days = var.long-window-days

  column-definitions = local.tgw-column-definitions
  columns            = var.tgw-columns
}

module "view-tgw" {
  source = "./trino-view"

  schema = var.schema
  name   = "tgw"

  source-schema = var.schema
  source-name   = var.tgw-table_name

  column-definitions = local.tgw-column-definitions
  columns            = var.tgw-columns
}

module "table-vpc" {
  source = "./flow-log-table"

  schema = var.schema
  name   = var.vpc-table_name

  bucket           = aws_s3_bucket.flow-logs.bucket
  file-path-prefix = var.vpc-log-raw-prefix

  history-days = var.long-window-days

  column-definitions = local.vpc-column-definitions
  columns            = var.vpc-columns
}

module "view-vpc" {
  source = "./trino-view"

  schema = var.schema
  name   = "vpc"

  source-schema = var.schema
  source-name   = var.vpc-table_name

  column-definitions = local.vpc-column-definitions
  columns            = var.vpc-columns
}
