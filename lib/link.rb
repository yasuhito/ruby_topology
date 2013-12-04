# -*- coding: utf-8 -*-
require 'rubygems'
require 'pio/lldp'

#
# Edges between two switches.
#
class Link
  attr_reader :dpid_a
  attr_reader :dpid_b
  attr_reader :port1
  attr_reader :port2

  def initialize(dpid, packet_in)
    lldp = Pio::Lldp.read(packet_in.data)
    @dpid_a = lldp.dpid
    @dpid_b = dpid
    @port1 = lldp.port_number
    @port2 = packet_in.in_port
  end

  def ==(other)
    (@dpid_a == other.dpid_a) &&
      (@dpid_b == other.dpid_b) &&
      (@port1 == other.port1) &&
      (@port2 == other.port2)
  end

  def <=>(other)
    to_s <=> other.to_s
  end

  def to_s
    format '%#x (port %d) <-> %#x (port %d)', dpid_a, port1, dpid_b, port2
  end

  def has?(dpid, port)
    ((@dpid_a == dpid) && (@port1 == port)) ||
      ((@dpid_b == dpid) && (@port2 == port))
  end
end

### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
