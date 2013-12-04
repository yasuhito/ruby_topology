# -*- coding: utf-8 -*-
require 'rubygems'
require 'pio/lldp'

#
# Edges between two switches.
#
class Host
  attr_reader :dpid_a
  attr_reader :ip_b
  attr_reader :port_a
  attr_reader :mac_b

  def initialize(dpid, packet_in)
    @dpid_a = dpid
    @ip_b = packet_in.ipv4_saddr.to_s
    @port_a = packet_in.in_port
    @mac_b = packet_in.macda.to_s
  end

  def ==(other)
    (@dpid_a == other.dpid_a) &&
      (@ip_b == other.ip_b) &&
      (@port_a == other.port_a) &&
      (@mac_b == other.mac_b)
  end

  def <=>(other)
    to_s <=> other.to_s
  end

  def to_s
    format '%#x (port %d) <-> %s (%s)', dpid_a, port_a, ip_b, mac_b
  end

  def has?(dpid, port)
    ((@dpid_a == dpid) && (@port_a == port))
  end
end

### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
