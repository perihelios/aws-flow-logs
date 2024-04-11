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

output "tgw-flow-log-fields" {
  value = join(" ", [
    for column in var.tgw-columns : "$${${replace(column, "_", "-")}}"
    if !local.tgw-column-definitions[column].synthetic
  ])
}

output "vpc-flow-log-fields" {
  value = join(" ", [
    for column in var.vpc-columns : "$${${replace(column, "_", "-")}}"
    if !local.vpc-column-definitions[column].synthetic
  ])
}
