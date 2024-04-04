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

variable "short-window-days" {
  type    = number
  default = 32
}

variable "medium-window-days" {
  type    = number
  default = 93
}

variable "long-window-days" {
  type    = number
  default = 398
}

variable "bucket-name" {
  type = string
}

variable "debug-dir" {
  type = string

  default = ""
}

variable "tgw-log-raw-prefix" {
  type    = string
  default = "raw/tgw"
}

variable "vpc-log-raw-prefix" {
  type    = string
  default = "raw/vpc"
}

variable "athena-workgroup-prefix" {
  type    = string
  default = "athena-workgroup"
}

variable "schema" {
  type    = string
  default = "flow_logs"
}

variable "tgw-table_name" {
  type    = string
  default = "__raw_tgw"
}

variable "vpc-table_name" {
  type    = string
  default = "__raw_vpc"
}

variable "tgw-columns" {
  type = list(string)

  default = [
    "srcaddr",
    "srcport",
    "dstaddr",
    "dstport",
    "type",
    "protocol_name",
    "flow_direction",

    "start",
    "end",

    "packets",
    "bytes",
    "tcp_flag_names",

    "region",
    "account_id",
    "tgw_id",
    "tgw_attachment_id",
    "tgw_pair_attachment_id",
    "resource_type",

    "tgw_src_vpc_account_id",
    "tgw_src_vpc_id",
    "tgw_src_subnet_id",
    "tgw_src_az_id",
    "tgw_src_eni",

    "tgw_dst_vpc_account_id",
    "tgw_dst_vpc_id",
    "tgw_dst_subnet_id",
    "tgw_dst_az_id",
    "tgw_dst_eni",

    "packets_lost_no_route",
    "packets_lost_blackhole",
    "packets_lost_mtu_exceeded",
    "packets_lost_ttl_expired",

    "pkt_src_aws_service",
    "pkt_dst_aws_service",

    "protocol",
    "tcp_flags",
    "log_status",
    "version",

    "partition_utc",
  ]

  validation {
    condition     = contains(var.tgw-columns, "account_id")
    error_message = "Column account_id is used as a partition key and is required"
  }

  validation {
    condition     = contains(var.tgw-columns, "region")
    error_message = "Column region is used as a partition key and is required"
  }

  validation {
    condition     = contains(var.tgw-columns, "partition_utc")
    error_message = "Column partition_utc is used as a partition key and is required"
  }

  validation {
    condition = length(setsubtract(var.tgw-columns, [
      "account_id",
      "bytes",
      "dstaddr",
      "dstport",
      "end",
      "flow_direction",
      "log_status",
      "packets",
      "packets_lost_blackhole",
      "packets_lost_mtu_exceeded",
      "packets_lost_no_route",
      "packets_lost_ttl_expired",
      "partition_utc",
      "pkt_dst_aws_service",
      "pkt_src_aws_service",
      "protocol",
      "protocol_name",
      "region",
      "resource_type",
      "srcaddr",
      "srcport",
      "start",
      "tcp_flag_names",
      "tcp_flags",
      "tgw_attachment_id",
      "tgw_dst_az_id",
      "tgw_dst_eni",
      "tgw_dst_subnet_id",
      "tgw_dst_vpc_account_id",
      "tgw_dst_vpc_id",
      "tgw_id",
      "tgw_pair_attachment_id",
      "tgw_src_az_id",
      "tgw_src_eni",
      "tgw_src_subnet_id",
      "tgw_src_vpc_account_id",
      "tgw_src_vpc_id",
      "type",
      "version",
    ])) == 0

    error_message = "Unrecognized columns: ${join(
      ", ",
      setsubtract(var.tgw-columns, [
        "account_id",
        "bytes",
        "dstaddr",
        "dstport",
        "end",
        "flow_direction",
        "log_status",
        "packets",
        "packets_lost_blackhole",
        "packets_lost_mtu_exceeded",
        "packets_lost_no_route",
        "packets_lost_ttl_expired",
        "partition_utc",
        "pkt_dst_aws_service",
        "pkt_src_aws_service",
        "protocol",
        "protocol_name",
        "region",
        "resource_type",
        "srcaddr",
        "srcport",
        "start",
        "tcp_flag_names",
        "tcp_flags",
        "tgw_attachment_id",
        "tgw_dst_az_id",
        "tgw_dst_eni",
        "tgw_dst_subnet_id",
        "tgw_dst_vpc_account_id",
        "tgw_dst_vpc_id",
        "tgw_id",
        "tgw_pair_attachment_id",
        "tgw_src_az_id",
        "tgw_src_eni",
        "tgw_src_subnet_id",
        "tgw_src_vpc_account_id",
        "tgw_src_vpc_id",
        "type",
        "version",
      ])
    )}"
  }
}

variable "vpc-columns" {
  type = list(string)

  default = [
    "pkt_srcaddr",
    "srcport",
    "pkt_dstaddr",
    "dstport",
    "type",
    "protocol_name",
    "flow_direction",

    "start",
    "end",

    "packets",
    "bytes",
    "tcp_flag_names",

    "region",
    "account_id",
    "vpc_id",
    "subnet_id",
    "az_id",
    "interface_id",
    "instance_id",
    "srcaddr",
    "dstaddr",

    "action",

    "pkt_src_aws_service",
    "pkt_dst_aws_service",
    "sublocation_id",
    "sublocation_type",
    "traffic_path_desc",

    "protocol",
    "tcp_flags",
    "traffic_path",
    "log_status",
    "version",

    "partition_utc",
  ]

  validation {
    condition     = contains(var.vpc-columns, "account_id")
    error_message = "Column account_id is used as a partition key and is required"
  }

  validation {
    condition     = contains(var.vpc-columns, "region")
    error_message = "Column region is used as a partition key and is required"
  }

  validation {
    condition     = contains(var.vpc-columns, "partition_utc")
    error_message = "Column partition_utc is used as a partition key and is required"
  }

  validation {
    condition = length(setsubtract(var.vpc-columns, [
      "account_id",
      "action",
      "az_id",
      "bytes",
      "dstaddr",
      "dstport",
      "end",
      "flow_direction",
      "instance_id",
      "interface_id",
      "log_status",
      "packets",
      "partition_utc",
      "pkt_dstaddr",
      "pkt_dst_aws_service",
      "pkt_srcaddr",
      "pkt_src_aws_service",
      "protocol",
      "protocol_name",
      "region",
      "srcaddr",
      "srcport",
      "start",
      "sublocation_id",
      "sublocation_type",
      "subnet_id",
      "tcp_flag_names",
      "tcp_flags",
      "traffic_path",
      "traffic_path_desc",
      "type",
      "version",
      "vpc_id",
    ])) == 0

    error_message = "Unrecognized columns: ${join(
      ", ",
      setsubtract(var.vpc-columns, [
        "account_id",
        "action",
        "az_id",
        "bytes",
        "dstaddr",
        "dstport",
        "end",
        "flow_direction",
        "instance_id",
        "interface_id",
        "log_status",
        "packets",
        "partition_utc",
        "pkt_dstaddr",
        "pkt_dst_aws_service",
        "pkt_srcaddr",
        "pkt_src_aws_service",
        "protocol",
        "protocol_name",
        "region",
        "srcaddr",
        "srcport",
        "start",
        "sublocation_id",
        "sublocation_type",
        "subnet_id",
        "tcp_flag_names",
        "tcp_flags",
        "traffic_path",
        "traffic_path_desc",
        "type",
        "version",
        "vpc_id",
      ])
    )}"
  }
}

data "aws_organizations_organization" "current" {}
data "aws_caller_identity" "current" {}
