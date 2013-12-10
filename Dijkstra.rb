# -*- coding: utf-8 -*-
require 'topology'
require 'set'
#
class Dijkstra
  def initialize
    @uncheck = []
    @checklist = []
    @prev = {}
    @path_len = {}
    @neighbor = {}
    @s_node = nil
    @d_node = nil
  end

  def shortest_path(dpid, packet_in, topology)
    setting dpid, topology
    find_sd_node dpid, packet_in, topology
    create_neighborlist topology
    if @flag == 1
      calc @s_node, @d_node, topology
      return @prev
    end
  end

  def calc(src, dist, topology)
    calc_initialize src, dist
    (1..@uncheck.size).each do
      @neighbor[src].each do |i|
        condition i
      end
      src = @checklist.shift
    end
  end

  private

  def find_sd_node(dpid, packet_in, topology)
    @flag = 0
    topology.each_link do |each|
      if each.dpid_a.to_s == packet_in.ipv4_daddr.to_s
        @s_node = dpid
        @d_node = each.dpid_b
        @flag = 1
      end
    end
  end

  def condition(i)
    if @uncheck.include?(i)
      @uncheck.delete(i)
      @path_len[i] = @path_len[src] + 1
      @prev[i] = src
      @checklist.push(i)
    end
  end

  def setting(dpid, topology)
    @flag = 0
    @path_len[dpid] = 0
    topology.each_switch do |each, ports|
      if each.class == Fixnum
        @uncheck.push(each) unless @uncheck.include?(each)
      end
    end
  end

  def calc_initialize(src, dist)
    @uncheck.delete(src)
    @uncheck.push(dist)
    @path_len[src] = 0
    @prev[src] = 0
  end

  def create_neighborlist(topology)
    @uncheck.each do |i|
      @neighbor[i] = []
      topology.each_link do |each|
        if (each.dpid_a == i) && !@neighbor[i].include?(i)
          @neighbor[i].push(each.dpid_b)
        end
      end
    end
  end
end
