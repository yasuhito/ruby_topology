# -*- coding: utf-8 -*-
require 'rubygems'
require 'pio/lldp'

#
# Edges between two switches.
#
class Link
  attr_reader :dpid_a
  attr_reader :dpid_b
  attr_reader :port_a
  attr_reader :port_b

  def initialize(dpid, packet_in)
    if packet_in.lldp?
      init_lldp(dpid, packet_in)
    elsif packet_in.ipv4?
      init_ipv4(dpid, packet_in)
    end
  end

  def ==(other)
    (@dpid_a == other.dpid_a) &&
      (@dpid_b == other.dpid_b) &&
      (@port_a == other.port_a) &&
      (@port_b == other.port_b)
  end

  def <=>(other)
    to_s <=> other.to_s
  end

  def to_s
    format '%#x (port %d) <-> %#x (port %d)', dpid_a, port_a, dpid_b, port_b
  end

  def has?(dpid, port)
    ((@dpid_a == dpid) && (@port_a == port)) ||
      ((@dpid_b == dpid) && (@port_b == port))
  end

  private

  def init_lldp(dpid, packet_in)
    lldp = Pio::Lldp.read(packet_in.data)
    @dpid1 = lldp.dpid
    @dpid2 = dpid
    @port1 = lldp.port_number
    @port2 = packet_in.in_port
  end

  def init_ipv4(dpid, packet_in)
    @dpid1 = packet_in.ipv4_saddr.to_s
    @dpid2 = dpid
    @port1 = 'host'
    @port2 = packet_in.in_port
  end
end

### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
