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

variable "schema" {
  type = string
}

variable "name" {
  type = string
}

variable "bucket" {
  type = string
}

variable "file-path-prefix" {
  type = string
}

variable "column-definitions" {
  type = map(object({
    description        = string
    hive-physical-type = string
    hive-logical-type  = string
    trino-type         = string
    nullable           = bool
    partition-key      = bool
    synthetic          = bool
    trino-projection   = string
  }))
}

variable "columns" {
  type = list(string)
}

variable "history-days" {
  type = number
}
