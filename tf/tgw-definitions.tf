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
  tgw-column-definitions = {
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

    resource_type = {
      description        = "capturing resource type (one of 'TransitGateway', 'TransitGatewayAttachment')"
      hive-physical-type = "string"
      hive-logical-type  = "string"
      trino-type         = "varchar"
      nullable           = false
      partition-key      = false
      synthetic          = false
      trino-projection   = "resource_type"
    }

    account_id = {
      description        = "capturing TGW account ID"
      hive-physical-type = "string"
      hive-logical-type  = "string"
      trino-type         = "varchar"
      nullable           = false
      partition-key      = true
      synthetic          = true
      trino-projection   = "account_id"
    }

    tgw_id = {
      description        = "capturing TGW ID"
      hive-physical-type = "string"
      hive-logical-type  = "string"
      trino-type         = "varchar"
      nullable           = false
      partition-key      = false
      synthetic          = false
      trino-projection   = "tgw_id"
    }

    tgw_attachment_id = {
      description        = "capturing TGW attachment ID"
      hive-physical-type = "string"
      hive-logical-type  = "string"
      trino-type         = "varchar"
      nullable           = false
      partition-key      = false
      synthetic          = false
      trino-projection   = "tgw_attachment_id"
    }

    tgw_src_vpc_account_id = {
      description        = "source TGW attachment ENI account ID"
      hive-physical-type = "string"
      hive-logical-type  = "string"
      trino-type         = "varchar"
      nullable           = true
      partition-key      = false
      synthetic          = false
      trino-projection   = "tgw_src_vpc_account_id"
      trino-projection   = "case tgw_src_vpc_account_id when '-' then null else tgw_src_vpc_account_id end tgw_src_vpc_account_id"
    }

    tgw_dst_vpc_account_id = {
      description        = "destination TGW attachment ENI account ID"
      hive-physical-type = "string"
      hive-logical-type  = "string"
      trino-type         = "varchar"
      nullable           = true
      partition-key      = false
      synthetic          = false
      trino-projection   = "case tgw_dst_vpc_account_id when '-' then null else tgw_dst_vpc_account_id end tgw_dst_vpc_account_id"
    }

    tgw_src_vpc_id = {
      description        = "source TGW attachment ENI VPC ID"
      hive-physical-type = "string"
      hive-logical-type  = "string"
      trino-type         = "varchar"
      nullable           = true
      partition-key      = false
      synthetic          = false
      trino-projection   = "case tgw_src_vpc_id when '-' then null else tgw_src_vpc_id end tgw_src_vpc_id"
    }

    tgw_dst_vpc_id = {
      description        = "destination TGW attachment ENI VPC ID"
      hive-physical-type = "string"
      hive-logical-type  = "string"
      trino-type         = "varchar"
      nullable           = true
      partition-key      = false
      synthetic          = false
      trino-projection   = "case tgw_dst_vpc_id when '-' then null else tgw_dst_vpc_id end tgw_dst_vpc_id"
    }

    tgw_src_subnet_id = {
      description        = "source TGW attachment ENI subnet ID"
      hive-physical-type = "string"
      hive-logical-type  = "string"
      trino-type         = "varchar"
      nullable           = true
      partition-key      = false
      synthetic          = false
      trino-projection   = "case tgw_src_subnet_id when '-' then null else tgw_src_subnet_id end tgw_src_subnet_id"
    }

    tgw_dst_subnet_id = {
      # TODO: Verify subnet and VPC meaning for TGW flow logs; adjust descriptions as necessary
      description        = "destination TGW attachment ENI subnet ID"
      hive-physical-type = "string"
      hive-logical-type  = "string"
      trino-type         = "varchar"
      nullable           = true
      partition-key      = false
      synthetic          = false
      trino-projection   = "case tgw_dst_subnet_id when '-' then null else tgw_dst_subnet_id end tgw_dst_subnet_id"
    }

    tgw_src_eni = {
      description        = "source TGW attachment ENI ID"
      hive-physical-type = "string"
      hive-logical-type  = "string"
      trino-type         = "varchar"
      nullable           = true
      partition-key      = false
      synthetic          = false
      trino-projection   = "case tgw_src_eni when '-' then null else tgw_src_eni end tgw_src_eni"
    }

    tgw_dst_eni = {
      description        = "destination TGW attachment ENI ID"
      hive-physical-type = "string"
      hive-logical-type  = "string"
      trino-type         = "varchar"
      nullable           = true
      partition-key      = false
      synthetic          = false
      trino-projection   = "case tgw_dst_eni when '-' then null else tgw_dst_eni end tgw_dst_eni"
    }

    tgw_src_az_id = {
      description        = "source TGW attachment ENI availability zone"
      hive-physical-type = "string"
      hive-logical-type  = "string"
      trino-type         = "varchar"
      nullable           = true
      partition-key      = false
      synthetic          = false
      trino-projection   = "case tgw_src_az_id when '-' then null else tgw_src_az_id end tgw_src_az_id"
    }

    tgw_dst_az_id = {
      description        = "destination TGW attachment ENI availability zone"
      hive-physical-type = "string"
      hive-logical-type  = "string"
      trino-type         = "varchar"
      nullable           = true
      partition-key      = false
      synthetic          = false
      trino-projection   = "case tgw_dst_az_id when '-' then null else tgw_dst_az_id end tgw_dst_az_id"
    }

    tgw_pair_attachment_id = {
      description        = "other (non-capturing) TGW attachment ID"
      hive-physical-type = "string"
      hive-logical-type  = "string"
      trino-type         = "varchar"
      nullable           = true
      partition-key      = false
      synthetic          = false
      trino-projection   = "case tgw_pair_attachment_id when '-' then null else tgw_pair_attachment_id end tgw_pair_attachment_id"
    }

    srcaddr = {
      description        = "packet source address"
      hive-physical-type = "string"
      hive-logical-type  = "string"
      trino-type         = "ipaddress"
      nullable           = true
      partition-key      = false
      synthetic          = false
      trino-projection   = "case srcaddr when '-' then null else cast(srcaddr as ipaddress) end srcaddr"
    }

    dstaddr = {
      description        = "packet destination address"
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
      description        = "packet source port (for TCP and UDP)"
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
      hive-physical-type = "bigint"
      hive-logical-type  = "bigint"
      trino-type         = "bigint"
      nullable           = false
      partition-key      = false
      synthetic          = false
      trino-projection   = "protocol"
    }

    packets = {
      description        = "packet count in aggregation window"
      hive-physical-type = "bigint"
      hive-logical-type  = "bigint"
      trino-type         = "bigint"
      nullable           = false
      partition-key      = false
      synthetic          = false
      trino-projection   = "packets"
    }

    bytes = {
      description        = "packet byte count in aggregation window"
      hive-physical-type = "bigint"
      hive-logical-type  = "bigint"
      trino-type         = "bigint"
      nullable           = false
      partition-key      = false
      synthetic          = false
      trino-projection   = "bytes"
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

    type = {
      description        = "traffic type (one of 'IPv4', 'IPv6', 'EFA')"
      hive-physical-type = "string"
      hive-logical-type  = "string"
      trino-type         = "varchar"
      nullable           = true
      partition-key      = false
      synthetic          = false
      trino-projection   = "case type when '-' then null else type end type"
    }

    packets_lost_no_route = {
      description        = "packets dropped due to no route in TGW route table"
      hive-physical-type = "bigint"
      hive-logical-type  = "bigint"
      trino-type         = "bigint"
      nullable           = true
      partition-key      = false
      synthetic          = false
      trino-projection   = "case when log_status = 'SKIPDATA' then null else packets_lost_no_route end packets_lost_no_route"
    }

    packets_lost_blackhole = {
      description        = "packets dropped due to blackhole route in TGW route table"
      hive-physical-type = "bigint"
      hive-logical-type  = "bigint"
      trino-type         = "bigint"
      nullable           = true
      partition-key      = false
      synthetic          = false
      trino-projection   = "case when log_status = 'SKIPDATA' then null else packets_lost_blackhole end packets_lost_blackhole"
    }

    packets_lost_mtu_exceeded = {
      description        = "packets dropped due to exceeding TGW MTU of 8500 bytes"
      hive-physical-type = "bigint"
      hive-logical-type  = "bigint"
      trino-type         = "bigint"
      nullable           = true
      partition-key      = false
      synthetic          = false
      trino-projection   = "case when log_status = 'SKIPDATA' then null else packets_lost_mtu_exceeded end packets_lost_mtu_exceeded"
    }

    packets_lost_ttl_expired = {
      description        = "packets dropped due to exceeding packet TTL (hop count)"
      hive-physical-type = "bigint"
      hive-logical-type  = "bigint"
      trino-type         = "bigint"
      nullable           = true
      partition-key      = false
      synthetic          = false
      trino-projection   = "case when log_status = 'SKIPDATA' then null else packets_lost_ttl_expired end packets_lost_ttl_expired"
    }

    tcp_flags = {
      description        = "packet TCP flag bitmask ('SYN' | 'ACK' | 'PSH' | 'FIN' | 'RST' | 'URG') (TCP only), OR-aggregated across all packets in capture window; 'ACK' never appears alone"
      hive-physical-type = "int"
      hive-logical-type  = "int"
      trino-type         = "integer"
      nullable           = true
      partition-key      = false
      synthetic          = false
      trino-projection   = "case when protocol = 6 then tcp_flags else null end tcp_flags"
    }

    region = {
      description        = "capturing TGW region name"
      hive-physical-type = "string"
      hive-logical-type  = "string"
      trino-type         = "varchar"
      nullable           = false
      partition-key      = true
      synthetic          = true
      trino-projection   = "region"
    }

    flow_direction = {
      description        = "packet direction with respect to capturing ENI (one of 'ingress', 'egress')"
      hive-physical-type = "string"
      hive-logical-type  = "string"
      trino-type         = "varchar"
      nullable           = true
      partition-key      = false
      synthetic          = false
      trino-projection   = "case flow_direction when '-' then null else flow_direction end flow_direction"
    }

    pkt_src_aws_service = {
      description        = "AWS service corresponding to packet source address, if applicable"
      hive-physical-type = "string"
      hive-logical-type  = "string"
      trino-type         = "varchar"
      nullable           = true
      partition-key      = false
      synthetic          = false
      trino-projection   = "case pkt_src_aws_service when '-' then null else pkt_src_aws_service end pkt_src_aws_service"
    }

    pkt_dst_aws_service = {
      description        = "AWS service corresponding to packet destination address, if applicable"
      hive-physical-type = "string"
      hive-logical-type  = "string"
      trino-type         = "varchar"
      nullable           = true
      partition-key      = false
      synthetic          = false
      trino-projection   = "case pkt_dst_aws_service when '-' then null else pkt_dst_aws_service end pkt_dst_aws_service"
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
      description        = "packet TCP flag names ('SYN', 'ACK', 'PSH', 'FIN', 'RST', 'URG') (TCP only), OR-aggregated across all packets in capture window; 'ACK' never appears alone"
      hive-physical-type = "array<string>"
      hive-logical-type  = "array<string>"
      trino-type         = "array(varchar)"
      nullable           = true
      partition-key      = false
      synthetic          = true

      trino-projection = <<EOF
        case
          when protocol = 6 then
            filter(
              array[
                if(bitwise_and(tcp_flags, 2) != 0 , 'SYN'),
                if(bitwise_and(tcp_flags, 16) != 0, 'ACK'),
                if(bitwise_and(tcp_flags, 8) != 0, 'PSH'),
                if(bitwise_and(tcp_flags, 1) != 0, 'FIN'),
                if(bitwise_and(tcp_flags, 4) != 0, 'RST'),
                if(bitwise_and(tcp_flags, 32) != 0, 'URG')
              ], x -> x is not null
            )
          else null
        end tcp_flag_names
      EOF
    }
  }

  tgw-trino-view-definition = {
    originalSql = "",
    catalog     = "awsdatacatalog",
    schema      = var.schema,
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
  }

  tgw-sql-projections = [
    for column-name in var.tgw-columns : trimspace(
      replace(
        local.tgw-column-definitions[column-name].trino-projection,
        "/(?m)^${regex("^\\s*", local.tgw-column-definitions[column-name].trino-projection)}/",
        "  "
      )
    )
  ]

  tgw-base-sql = "select\n  ${
    join(",\n  ", local.tgw-sql-projections)
  }\nfrom \"${var.schema}\".\"${var.tgw-table-name}\""
}
