# -*- coding: utf-8 -*-
require 'rubygems'
require 'pio/lldp'

#
# Edges between host and switch.
#
class Host 
  attr_reader :dpid1
  attr_reader :port1
  attr_reader :ipaddr2
  attr_reader :mac2

  def initialize(dpid, packet_in)
    @dpid1 = dpid
    @port1 = packet_in.in_port
    @ipaddr2 = packet_in.ipv4_saddr
    @mac2 = packet_in.macsa
  end

  def ==(other)
    (@dpid1 == other.dpid1) &&
      (@port1 == other.port1) &&
      (@ipaddr2.to_s == other.ipaddr2.to_s) &&
      (@mac2.to_s == other.mac2.to_s) 
  end

  def <=>(other)
    to_s <=> other.to_s
  end

  def to_s
    format '%#x (port %d) <-> (host %s)', dpid1, port1, ipaddr2.to_s
  end

  #def has?(dpid, port)
  #  ((@dpid1 == dpid) && (@port1 == port)) ||
  #    ((@dpid2 == dpid) && (@port2 == port))
  #end
end

### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
