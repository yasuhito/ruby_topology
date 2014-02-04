# -*- coding: utf-8 -*-
require 'forwardable'
require 'link'
require 'observer'
require 'trema-extensions/port'

#
# Topology information containing the list of known switches, ports,
# and links.
#
class Topology
  include Observable
  extend Forwardable

  def_delegator :@ports, :each_pair, :each_switch
  def_delegator :@links, :each, :each_link
  def_delegator :@hosts, :each_pair, :each_host

  def initialize(view)
    @ports = Hash.new { [].freeze }
    @links = []
    @hosts = {}
    add_observer view
  end

  def delete_switch(dpid)
    @ports[dpid].each do | each |
      delete_port each
    end
    @ports.delete dpid
  end

  def update_port(port)
    if port.down?
      delete_port port
    elsif port.up?
      add_port port
    end
  end

  def add_port(port)
    @ports[port.dpid] += [port]
  end

  def delete_port(port)
    @ports[port.dpid] -= [port]
    delete_link_by port
  end

  def add_link_by(dpid, packet_in)
#    fail 'Not an LLDP packet!' unless packet_in.lldp?
    begin
      maybe_add_link Link.new(dpid, packet_in)
    rescue
      return
    end
    changed
    notify_observers self
  end

  def add_host(dpid, packet_in)
    ip = packet_in.ipv4_saddr.to_s
    @hosts[ip] = 10_000 unless is_allzero(ip)
  end

  private

  def maybe_add_link(link)
    fail 'The link already exists.' if @links.include?(link)
    @links << link
  end

  def delete_link_by(port)
    @links.each do |each|
      if each.has?(port.dpid, port.number)
        changed
        @links -= [each]
      end
    end
    notify_observers self
  end

  def is_allzero(ip)
    bit = ip.split('.')
    b1 = (bit[0].to_i == 0)
    b2 = (bit[1].to_i == 0)
    b3 = (bit[2].to_i == 0)
    b4 = (bit[3].to_i == 0)
    if b1 && b2 && b3 && b4
      return true
    else
      return false
    end
  end

end

### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
