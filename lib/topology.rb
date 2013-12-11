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
  def_delegator :@hosts, :each, :each_host

  def initialize(view)
    @ports = Hash.new { [].freeze }
    @links = []
    @hosts = Hash.new { [].freeze }
    @table = []
    @table2 = Hash.new { |hash, key| hash[key] = [] }
    @i = 0
    @cost = []
    @done = []
    @from = []
    @host_list = {}
    add_observer view
    @flow = []
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
    fail 'Not an LLDP packet!' unless packet_in.lldp?
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
    return if ip == '0.0.0.0'
    @hosts[ip] = packet_in.in_port
    @host_list[ip] = dpid
    begin
      maybe_add_link Link.new(dpid, packet_in)
    rescue
      return
    end
    changed
    notify_observers self
  end

  def route(packet_in)
    source = @host_list[packet_in.ipv4_saddr.to_s]
    dest = @host_list[packet_in.ipv4_daddr.to_s]
    @i = 0
    @links.each do |each|
      @table[@i] = [each.dpid_a.to_s, each.dpid_b.to_s]
      @i = @i + 1
    end
    @table.each { |odd, even|@table2[even] << odd }
    @table2.each_key do |key|
      @cost = [key, nil]
      @done = [key, false]
      @from = [key, nil]
    end
    @cost[source] = 0
    dijkstra
    port = @hosts[packet_in.ipv4_daddr.to_s]
    @i = 0
    loop do
      @flow[@i] = [dest, port]
      next_dest = @from[dest]
      if dest == source
        @flow[@i].push(@hosts[packet_in.ipv4_saddr.to_s])
        break
      end
      @links.each do |each|
        if each.dpid_a == next_dest && each.dpid_b == dest
          port = each.port_a.to_i
          @flow[@i].push(each.port_b.to_i)
        end
      end
      dest = next_dest
      @i = @i + 1
    end
    return @flow
  end

  private

  def dijkstra
    loop do
      next_node = nil
      @table2.each_key do |key|
        next if @done[key.to_i] || @cost[key.to_i].nil?
        next_node = key.to_i if next_node.nil? || @cost[key.to_i] < @cost[next_node]
      end
      break if next_node.nil?
      @done[next_node] = true
      @i = 0
      loop do
        break if @table2[next_node.to_s][@i].nil?
        reachble_node = @table2[next_node.to_s][@i].to_i
        reachble_cost = @cost[next_node] + 1
        @i = @i + 1
        if @cost[reachble_node].nil? || reachble_cost < @cost[reachble_node]
          @cost[reachble_node] = reachble_cost
          @from[reachble_node] = next_node
        end
      end
    end
  end

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

end

### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
