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

resource "local_file" "debug-file" {
  for_each = var.debug-dir == "" ? {} : {
    tgw-sql = {
      filename = "${var.debug-dir}/tgw.sql"
      value    = module.view-tgw.sql
    }

    tgw-json = {
      filename = "${var.debug-dir}/tgw.json"
      value    = module.view-tgw.json
    }

    vpc-sql = {
      filename = "${var.debug-dir}/vpc.sql"
      value    = module.view-vpc.sql
    }

    vpc-json = {
      filename = "${var.debug-dir}/vpc.json"
      value    = module.view-vpc.json
    }
  }

  filename        = each.value.filename
  content         = each.value.value
  file_permission = "0664"
}
