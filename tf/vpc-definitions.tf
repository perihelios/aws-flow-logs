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

# TODO: Confirm nullability of all fields (using NODATA and SKIPDATA records)

locals {
  vpc-column-definitions = {
    version = {
      description        = "flow log version"
      hive-physical-type = "int"
      hive-logical-type  = "int"
      trino-type         = "integer"
      nullable           = false
      partition-key      = false
      synthetic          = false
      trino-projection   = "version"
    }

    account_id = {
      description        = "capturing ENI account ID"
      hive-physical-type = "string"
      hive-logical-type  = "string"
      trino-type         = "varchar"
      nullable           = false
      partition-key      = true
      synthetic          = true
      trino-projection   = "account_id"
    }

    interface_id = {
      description        = "capturing ENI ID"
      hive-physical-type = "string"
      hive-logical-type  = "string"
      trino-type         = "varchar"
      nullable           = false
      partition-key      = false
      synthetic          = false
      trino-projection   = "interface_id"
    }

    srcaddr = {
      description        = "packet source address for ingress traffic; capturing ENI private address for egress traffic"
      hive-physical-type = "string"
      hive-logical-type  = "string"
      trino-type         = "ipaddress"
      nullable           = true
      partition-key      = false
      synthetic          = false
      trino-projection   = "case srcaddr when '-' then null else cast(srcaddr as ipaddress) end srcaddr"
    }

    dstaddr = {
      description        = "packet destination address for egress traffic; capturing ENI private address for ingress traffic"
      hive-physical-type = "string"
      hive-logical-type  = "string"
      trino-type         = "ipaddress"
      nullable           = true
      partition-key      = false
      synthetic          = false
      trino-projection   = "case dstaddr when '-' then null else cast(dstaddr as ipaddress) end dstaddr"
    }

    srcport = {
      description        = "packet source port (for TCP and UDP)"
      hive-physical-type = "int"
      hive-logical-type  = "int"
      trino-type         = "integer"
      nullable           = true
      partition-key      = false
      synthetic          = false
      trino-projection   = "case when protocol = 6 or protocol = 17 then srcport else null end srcport"
    }

    dstport = {
      description        = "packet destination port (for TCP and UDP)"
      hive-physical-type = "int"
      hive-logical-type  = "int"
      trino-type         = "integer"
      nullable           = true
      partition-key      = false
      synthetic          = false
      trino-projection   = "case when protocol = 6 or protocol = 17 then dstport else null end dstport"
    }

    protocol = {
      description        = "packet IANA protocol number"
      hive-physical-type = "int"
      hive-logical-type  = "int"
      trino-type         = "integer"
      nullable           = true
      partition-key      = false
      synthetic          = false
      trino-projection   = "case log_status when 'OK' then protocol else null end protocol"
    }

    packets = {
      description        = "packet count in aggregation window"
      hive-physical-type = "bigint"
      hive-logical-type  = "bigint"
      trino-type         = "bigint"
      nullable           = true
      partition-key      = false
      synthetic          = false
      // TODO: Check NODATA and coalesce to 0 if null
      trino-projection = "case log_status when 'SKIPDATA' then null else packets end packets"
    }

    bytes = {
      description        = "packet byte count in aggregation window"
      hive-physical-type = "bigint"
      hive-logical-type  = "bigint"
      trino-type         = "bigint"
      nullable           = true
      partition-key      = false
      synthetic          = false
      // TODO: Check NODATA and coalesce to 0 if null
      trino-projection = "case log_status when 'SKIPDATA' then null else bytes end bytes"
    }

    start = {
      description        = "start of aggregation window"
      hive-physical-type = "bigint"
      hive-logical-type  = "timestamp"
      trino-type         = "timestamp(0) with time zone"
      nullable           = false
      partition-key      = false
      synthetic          = false
      trino-projection   = "cast(from_unixtime(start) as timestamp(0) with time zone) start"
    }

    end = {
      description        = "end of aggregation window"
      hive-physical-type = "bigint"
      hive-logical-type  = "timestamp"
      trino-type         = "timestamp(0) with time zone"
      nullable           = false
      partition-key      = false
      synthetic          = false
      trino-projection   = "cast(from_unixtime(\"end\") as timestamp(0) with time zone) \"end\""
    }

    action = {
      description        = "result of filtering by NACLs and security groups (one of 'ACCEPT', 'REJECT')"
      hive-physical-type = "string"
      hive-logical-type  = "string"
      trino-type         = "varchar"
      nullable           = true
      partition-key      = false
      synthetic          = false
      trino-projection   = "nullif(action, '-') action"
    }

    log_status = {
      description        = "flow log status (one of 'OK', 'NODATA', 'SKIPDATA')"
      hive-physical-type = "string"
      hive-logical-type  = "string"
      trino-type         = "varchar"
      nullable           = false
      partition-key      = false
      synthetic          = false
      trino-projection   = "log_status"
    }

    vpc_id = {
      description        = "capturing ENI VPC ID"
      hive-physical-type = "string"
      hive-logical-type  = "string"
      trino-type         = "varchar"
      nullable           = true
      partition-key      = false
      synthetic          = false
      trino-projection   = "nullif(vpc_id, '-') vpc_id"
    }

    subnet_id = {
      description        = "capturing ENI VPC subnet ID"
      hive-physical-type = "string"
      hive-logical-type  = "string"
      trino-type         = "varchar"
      nullable           = true
      partition-key      = false
      synthetic          = false
      trino-projection   = "nullif(subnet_id, '-') subnet_id"
    }

    instance_id = {
      description        = "capturing ENI EC2 instance ID (if ENI attached to EC2 instance)"
      hive-physical-type = "string"
      hive-logical-type  = "string"
      trino-type         = "varchar"
      nullable           = true
      partition-key      = false
      synthetic          = false
      trino-projection   = "nullif(instance_id, '-') instance_id"
    }

    tcp_flags = {
      description        = "packet TCP flag bitmask (SYN | ACK | FIN | RST) (TCP only), OR-aggregated across all packets in capture window; ACK never appears alone"
      hive-physical-type = "int"
      hive-logical-type  = "int"
      trino-type         = "integer"
      nullable           = true
      partition-key      = false
      synthetic          = false
      trino-projection   = "case protocol when 6 then tcp_flags else null end tcp_flags"
    }

    type = {
      description        = "traffic type (one of 'IPv4', 'IPv6', 'EFA')"
      hive-physical-type = "string"
      hive-logical-type  = "string"
      trino-type         = "varchar"
      nullable           = true
      partition-key      = false
      synthetic          = false
      trino-projection   = "nullif(type, '-') type"
    }

    pkt_srcaddr = {
      description        = "packet source address"
      hive-physical-type = "string"
      hive-logical-type  = "string"
      trino-type         = "ipaddress"
      nullable           = true
      partition-key      = false
      synthetic          = false
      trino-projection   = "case pkt_srcaddr when '-' then null else cast(pkt_srcaddr as ipaddress) end pkt_srcaddr"
    }

    pkt_dstaddr = {
      description        = "packet destination address"
      hive-physical-type = "string"
      hive-logical-type  = "string"
      trino-type         = "ipaddress"
      nullable           = true
      partition-key      = false
      synthetic          = false
      trino-projection   = "case pkt_dstaddr when '-' then null else cast(pkt_dstaddr as ipaddress) end pkt_dstaddr"
    }

    region = {
      description        = "capturing ENI region name"
      hive-physical-type = "string"
      hive-logical-type  = "string"
      trino-type         = "varchar"
      nullable           = false
      partition-key      = true
      synthetic          = true
      trino-projection   = "region"
    }

    az_id = {
      description        = "capturing ENI availability zone ID"
      hive-physical-type = "string"
      hive-logical-type  = "string"
      trino-type         = "varchar"
      nullable           = true
      partition-key      = false
      synthetic          = false
      trino-projection   = "nullif(az_id, '-') az_id"
    }

    sublocation_type = {
      description        = "capturing ENI sublocation type (one of 'wavelength', 'outpost', 'localzone')"
      hive-physical-type = "string"
      hive-logical-type  = "string"
      trino-type         = "varchar"
      nullable           = true
      partition-key      = false
      synthetic          = false
      trino-projection   = "nullif(sublocation_type, '-') sublocation_type"
    }

    sublocation_id = {
      description        = "capturing ENI sublocation ID"
      hive-physical-type = "string"
      hive-logical-type  = "string"
      trino-type         = "varchar"
      nullable           = true
      partition-key      = false
      synthetic          = false
      trino-projection   = "nullif(sublocation_id, '-') sublocation_id"
    }

    pkt_src_aws_service = {
      description        = "packet source address AWS service type, if any"
      hive-physical-type = "string"
      hive-logical-type  = "string"
      trino-type         = "varchar"
      nullable           = true
      partition-key      = false
      synthetic          = false
      trino-projection   = "nullif(pkt_src_aws_service, '-') pkt_src_aws_service"
    }

    pkt_dst_aws_service = {
      description        = "packet destination address AWS service type, if any"
      hive-physical-type = "string"
      hive-logical-type  = "string"
      trino-type         = "varchar"
      nullable           = true
      partition-key      = false
      synthetic          = false
      trino-projection   = "nullif(pkt_dst_aws_service, '-') pkt_dst_aws_service"
    }

    flow_direction = {
      description        = "packet direction with respect to capturing ENI (one of 'ingress', 'egress')"
      hive-physical-type = "string"
      hive-logical-type  = "string"
      trino-type         = "varchar"
      nullable           = true
      partition-key      = false
      synthetic          = false
      trino-projection   = "nullif(flow_direction, '-') flow_direction"
    }

    traffic_path = {
      description        = "packet traffic path (for egress packets, only)"
      hive-physical-type = "int"
      hive-logical-type  = "int"
      trino-type         = "integer"
      nullable           = true
      partition-key      = false
      synthetic          = false
      trino-projection   = "case when flow_direction = 'egress' and traffic_path > 0 then traffic_path else null end traffic_path"
    }


    # Additional partition key fields

    partition_utc = {
      description        = "yyyy[/mm[/dd[/hh]]] data partition (in UTC timezone)"
      hive-physical-type = "string"
      hive-logical-type  = "string"
      trino-type         = "varchar"
      nullable           = false
      partition-key      = true
      synthetic          = true
      trino-projection   = "partition_utc"
    }


    # Lookup table fields

    protocol_name = {
      description        = "packet IANA protocol name (keyword)"
      hive-physical-type = "string"
      hive-logical-type  = "string"
      trino-type         = "varchar"
      nullable           = true
      partition-key      = false
      synthetic          = true
      trino-projection   = <<EOF
        case
          when protocol < 146 then
            array[
              'HOPOPT', 'ICMP', 'IGMP', 'GGP', 'IPv4', 'ST', 'TCP', 'CBT', 'EGP', 'IGP', 'BBN-RCC-MON', 'NVP-II', 'PUP',
              'ARGUS', 'EMCON', 'XNET', 'CHAOS', 'UDP', 'MUX', 'DCN-MEAS', 'HMP', 'PRM', 'XNS-IDP', 'TRUNK-1',
              'TRUNK-2', 'LEAF-1', 'LEAF-2', 'RDP', 'IRTP', 'ISO-TP4', 'NETBLT', 'MFE-NSP', 'MERIT-INP', 'DCCP', '3PC',
              'IDPR', 'XTP', 'DDP', 'IDPR-CMTP', 'TP++', 'IL', 'IPv6', 'SDRP', 'IPv6-Route', 'IPv6-Frag', 'IDRP',
              'RSVP', 'GRE', 'DSR', 'BNA', 'ESP', 'AH', 'I-NLSP', 'SWIPE', 'NARP', 'Min-IPv4', 'TLSP', 'SKIP',
              'IPv6-ICMP', 'IPv6-NoNxt', 'IPv6-Opts', null, 'CFTP', null, 'SAT-EXPAK', 'KRYPTOLAN', 'RVD', 'IPPC', null,
              'SAT-MON', 'VISA', 'IPCV', 'CPNX', 'CPHB', 'WSN', 'PVP', 'BR-SAT-MON', 'SUN-ND', 'WB-MON', 'WB-EXPAK',
              'ISO-IP', 'VMTP', 'SECURE-VMTP', 'VINES', 'IPTM', 'NSFNET-IGP', 'DGP', 'TCF', 'EIGRP', 'OSPFIGP',
              'Sprite-RPC', 'LARP', 'MTP', 'AX.25', 'IPIP', 'MICP', 'SCC-SP', 'ETHERIP', 'ENCAP', null, 'GMTP', 'IFMP',
              'PNNI', 'PIM', 'ARIS', 'SCPS', 'QNX', 'A/N', 'IPComp', 'SNP', 'Compaq-Peer', 'IPX-in-IP', 'VRRP', 'PGM',
              null, 'L2TP', 'DDX', 'IATP', 'STP', 'SRP', 'UTI', 'SMP', 'SM', 'PTP', 'ISIS over IPv4', 'FIRE', 'CRTP',
              'CRUDP', 'SSCOPMCE', 'IPLT', 'SPS', 'PIPE', 'SCTP', 'FC', 'RSVP-E2E-IGNORE', 'Mobility Header', 'UDPLite',
              'MPLS-in-IP', 'manet', 'HIP', 'Shim6', 'WESP', 'ROHC', 'Ethernet', 'AGGFRAG', 'NSH'
            ][protocol + 1]
          else null
        end protocol_name
      EOF
    }

    tcp_flag_names = {
      description        = "packet TCP flag names ('SYN', 'ACK', 'FIN', 'RST') (TCP only), OR-aggregated across all packets in capture window; 'ACK' never appears alone"
      hive-physical-type = "array<string>"
      hive-logical-type  = "array<string>"
      trino-type         = "array(varchar)"
      nullable           = true
      partition-key      = false
      synthetic          = true
      trino-projection   = <<EOF
        case protocol
          when 6 then
            filter(
              array[
                if(bitwise_and(tcp_flags, 2) != 0 , 'SYN'),
                if(bitwise_and(tcp_flags, 16) != 0, 'ACK'),
                if(bitwise_and(tcp_flags, 1) != 0, 'FIN'),
                if(bitwise_and(tcp_flags, 4) != 0, 'RST')
              ], x -> x is not null
            )
          else null
        end tcp_flag_names
      EOF
    }

    traffic_path_desc = {
      description        = "packet traffic path description (for egress packets, only)"
      hive-physical-type = "string"
      hive-logical-type  = "string"
      trino-type         = "varchar"
      nullable           = true
      partition-key      = false
      synthetic          = true
      trino-projection   = <<EOF
        case
          when flow_direction = 'egress' and traffic_path >= 1 and traffic_path <= 8 then
            array[
              'intra-VPC',
              'IGW/gateway VPC endpoint',
              'VGW',
              'intra-region VPC peering',
              'inter-region VPC peering',
              'local gateway',
              'gateway VPC endpoint',
              'IGW'
            ][traffic_path]
          else null
        end traffic_path_desc
      EOF
    }
  }

  vpc-hive-columns = [
    for column in var.vpc-columns : {
      name = column
      type = local.vpc-column-definitions[column].hive-logical-type
      comment = "Type: ${
        local.vpc-column-definitions[column].trino-type
        }${
        local.vpc-column-definitions[column].nullable ? " (nullable)" : ""
        } \u2022 Description: ${
        local.vpc-column-definitions[column].description
      }"
    } if !local.vpc-column-definitions[column].partition-key
  ]

  vpc-hive-partition-keys = [
    for column in var.vpc-columns : {
      name = column
      type = local.vpc-column-definitions[column].hive-logical-type
      comment = "Type: ${
        local.vpc-column-definitions[column].trino-type
        }${
        local.vpc-column-definitions[column].nullable ? " (nullable)" : ""
        } \u2022 Description: ${
        local.vpc-column-definitions[column].description
      }"
    } if local.vpc-column-definitions[column].partition-key
  ]

  vpc-trino-view-definition = {
    originalSql = "<this value must be overwritten and provided by caller>",
    catalog     = "awsdatacatalog",
    schema      = var.schema,
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
  }

  vpc-sql-projections = [
    for column-name in var.vpc-columns : trimspace(
      replace(
        local.vpc-column-definitions[column-name].trino-projection,
        "/(?m)^${regex("^\\s*", local.vpc-column-definitions[column-name].trino-projection)}/",
        "  "
      )
    )
  ]

  vpc-base-sql = "select\n  ${
    join(",\n  ", local.vpc-sql-projections)
  }\nfrom \"${var.schema}\".\"${var.vpc-table-name}\""
}
