require 'pp'
require 'topology'
require 'set'
#
class Dijkstra
  def initialize
    @uncheck = Set.new
    @path = []
  end

  def shortest_path dpid, packet_in, topology
    topology.each_switch do |dpid|
      uncheck.add(dpid)
    end
    topology.each_link do |each|
      if each.dpid_a.to_s == packet_in.ipv4_daddr.to_s
        src = dpid
        dist = each.dpid_b
        calc src, dist, topology
      end
    end
  end

  def calc src, dist, topology
    puts "from " + src.to_s + " to " + dist.to_s
    puts uncheck


  end

end
