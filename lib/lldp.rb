require "rubygems"

require "bindata"
require "lldp-frame"

$TYPE_CHASSIS_ID = "\x02"
$TYPE_PORT_ID = "\x04"
$TYPE_TTL = "\x06"
$TYPE_PORT_DESC = "\x08"
$TYPE_SYSTEM_NAME = "\x0a"
$TYPE_SYSTEM_DESC = "\x0c"
$TYPE_CAPABILITIES = "\x0e"
$TYPE_MANAGEMENT_ADDR = "\x10"

class Lldp
 #LLDPのオプショナルTLVに対応する。Typeを1byteで区切っている。Organization_Specific(127)実装してない。
  def read raw_data
    lldp = {}
    tlv_header_len = 2
    idx = 0
    while ( raw_data[ idx, tlv_header_len ] != "\x00\x00" ) && ( idx + tlv_header_len < raw_data.size )
      tlv_known = false
      case raw_data[ idx, 1 ]
      when $TYPE_CHASSIS_ID
        tlv_known = true
        tlv_length = raw_data[ idx + 1, 1 ].unpack( "U*" ).join.to_i
        lldp[ "chassis_id_type" ] = chassis_id_subtype( raw_data[ idx + 2, 1 ].unpack( "U*" ).join.to_i )
        lldp[ "chassis_id" ] = raw_data[ idx + 3, tlv_length -1 ].unpack( "H*" ).join(",")
        idx += tlv_length + tlv_header_len
      when $TYPE_PORT_ID
        tlv_known = true
        tlv_length = raw_data[ idx+1, 1 ].unpack( "U*" ).join.to_i
        lldp[ "port_id_type" ] = port_id_subtype( raw_data[ idx + 2, 1 ].unpack( "U*" ).join.to_i )
        lldp[ "port_id" ] = raw_data[ idx + 3, tlv_length ].unpack( "A*" ).join(",")
        idx += tlv_length + tlv_header_len
      when $TYPE_TTL
        tlv_known = true
        tlv_length = raw_data[ idx + 1, 1 ].unpack( "U*" ).join.to_i
        lldp[ "ttl" ] = raw_data[ idx + tlv_header_len, tlv_length ].unpack( "U*" ).join.to_i
        idx += tlv_length + tlv_header_len
      when $TYPE_PORT_DESC
        tlv_known = true
        tlv_length = raw_data[ idx + 1, 1 ].unpack( "U*" ).join.to_i
        lldp[ "port_description" ] = raw_data[ idx + tlv_header_len, tlv_length ]
        idx += tlv_length + tlv_header_len
      when $TYPE_SYSTEM_NAME
        tlv_known = true
        tlv_length = raw_data[ idx + 1, 1 ].unpack( "U*" ).join.to_i
        lldp[ "system_name" ] = raw_data[ idx + tlv_header_len, tlv_length ]
        idx += tlv_length + tlv_header_len
      when $TYPE_SYSTEM_DESC
        tlv_known = true
        tlv_length = raw_data[ idx + 1, 1 ].unpack( "U*" ).join.to_i
        lldp[ "system_description" ] = raw_data[idx + tlv_header_len, tlv_length ]
        idx += tlv_length + tlv_header_len
      when $TYPE_CAPABILITIES
        tlv_known = true
        tlv_length = raw_data[ idx + 1,1 ].unpack( "U*" ).join.to_i
        lldp[ "capabilty" ] = decode_capabilities( raw_data[ idx + tlv_header_len, tlv_length - 2] )
        lldp[ "enabled_capability" ] = decode_capabilities( raw_data[idx + tlv_header_len, tlv_length -2 ] )
        idx += tlv_length + tlv_header_len
      when $TYPE_MANAGEMENT_ADDR
        tlv_known = true
        tlv_length = raw_data[ idx + 1, 1 ].unpack("U*").join.to_i
        addr_length = raw_data[ idx + tlv_header_len, 1 ].unpack("U*").join.to_i
        lldp[ "address_type" ] = raw_data[ idx + tlv_header_len + 1, 1 ].unpack( "U*" ).join.to_i
        lldp[ "address" ] = raw_data[ idx + tlv_header_len + 2, addr_length -1 ].unpack("C4").join(".")
        lldp[ "interface_type" ] = raw_data[ idx + tlv_header_len + addr_length + 1, 1 ].unpack( "U*" ).join.to_i
        lldp[ "interface" ] = raw_data[ idx + tlv_header_len + addr_length + 2, 4 ].unpack( "U*" ).join.to_i
        oid_raw_dataing_length = raw_data[ idx + tlv_header_len + addr_length + 7, 1 ].unpack( "S*" ).join.to_i
        if oid_raw_dataing_length > 0
          lldp[ "interface" ] = raw_data[ idx + tlv_header_len + addr_length + 8, oid_raw_dataing_length ]
        end
        idx += tlv_length + tlv_header_len
      else
        tlv_length = raw_data[idx+1,1].unpack("S*").join.to_i
        idx += tlv_length + tlv_header_len
      end
    end
    puts "=============================================================="
    lldp.each{ | key, value |  puts "****  #{ key }  ==>>  #{ value } ****" }  
    puts "=============================================================="
    return lldp
  end

  def decode_capabilities lldp_cap
    list = []
    caps = ( lldp_cap.unpack("B*").to_s ).reverse.split('1',-1).inject([]){|ret,i| ret << i.size + (ret.last.nil? ? 0 : ret.last + 1); ret }[0..-2]
    caps.each do | each |
      case each + 1
      when 1
        list << "Other,"
      when 2
        list << "Repeater,"
      when 3
        list << "MAC Bridge,"
      when 4
        list << "WLAN Access Point,"
      when 5
        list << "Router,"
      when 6
        list << "Telephone,"
      when 7
        list << "DOCSIS cable device,"
      when 8
        list << "Station Only,"
      when 9
        list << "C-VLAN Component of a VLAN Bridge,"
      when 10
        list << "S-VLAN Component of a VLAN Bridge,"
      when 11
        list << "Two-port MAC Relay (TPMR),"
      else
        list << "Reserved,"
      end
    end
    return list
  end

  def chassis_id_subtype sub_type
    case sub_type
    when 0
      subtype =  "Reserved"
    when 1
      subtype =  "Chassis component"
    when 2
      subtype =  "Interface alias"
    when 3
      subtype =  "Port component"
    when 4
      subtype =  "MAC address"
    when 5
      subtype =  "Network address"
    when 6
      subtype =  "Interface name"
    when 7
      subtype =  "Locally assigned"
    when 8..255
      subtype =  "Reserved"
    end
  end

  def port_id_subtype sub_type
    case sub_type
    when 0
      subtype =  "Reserved"
    when 1
      subtype =  "Interface alias"
    when 2
      subtype =  "Port component"
    when 3
      subtype =  "MAC address"
    when 4
      subtype =  "Network address"
    when 5
      subtype =  "Interface name"
    when 6
      subtype =  "Agent circuit ID"
    when 7
      subtype =  "Locally assigned"
    when 8..255
      subtype =  "Reserved"
    end
  end


  def initialize dpid = nil , port_number = nil, destination_mac = 0x0180c200000e
    @frame = LldpFrame.new
    @frame.destination_mac = destination_mac
    @frame.chassis_id.subtype = 7
    @frame.chassis_id = BinData::Uint64le.new( dpid ).to_binary_s
    @frame.port_id.subtype = 7
    @frame.port_id = BinData::Uint16le.new( port_number ).to_binary_s
    @frame.ttl = 120
  end


  def dpid
    @frame.chassis_id.unpack( "Q" )[ 0 ]
  end


  def port_number
    @frame.port_id.unpack( "S" )[ 0 ]
  end


  def to_binary
    @frame.to_binary_s + "\000" * ( 64 - @frame.num_bytes )
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
