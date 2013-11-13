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
    packet_check packet_in
    @dpid_a = @flag ? @lldp.dpid : @lldp.ipv4_saddr.to_s
    @dpid_b = dpid
    @port_a = @flag ? @lldp.port_number : 1
    @port_b = packet_in.in_port
  end

  def packet_check(packet_in)
    if packet_in.lldp?
      @lldp = Pio::Lldp.read(packet_in.data)
      @flag = true
    elsif packet_in.ipv4?
      @lldp = packet_in
      @flag = false
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
    if dpid_a.class == String
      to_s_host
    else
      to_s_switch
    end
  end

  def to_s_host
    format '%#s (port %d) <-> %#x (port %d)', dpid_a, port_a, dpid_b, port_b
  end

  def to_s_switch
    format '%#x (port %d) <-> %#x (port %d)', dpid_a, port_a, dpid_b, port_b
  end

  def has?(dpid, port)
    ((@dpid_a == dpid) && (@port_a == port)) ||
      ((@dpid_b == dpid) && (@port_b == port))
  end
end

### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
