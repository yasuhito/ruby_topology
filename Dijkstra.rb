require 'pp'
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
  end

  def shortest_path dpid, packet_in, topology
    @path_len[dpid] = 0
    topology.each_switch do |each, ports|
      if each.class == Fixnum
        if !@uncheck.include?(each)
          @uncheck.push(each)
        end
      end
    end
    flag = 0
    src, dist = nil
    topology.each_link do |each|
      if each.dpid_a.to_s == packet_in.ipv4_daddr.to_s
        src = dpid
        dist = each.dpid_b
        flag = 1
      end
    end
    create_neighborlist topology
    if flag == 1
      calc src, dist, topology
      return @prev
    end
  end


  def calc src, dist, topology
    calc_initialize src, dist
    len = 1
    puts "from " + src.to_s + " to " + dist.to_s
    max = @uncheck.size
    for num in 1..max do

      @neighbor[src].each do |i|
        if @uncheck.include?(i)
          @uncheck.delete(i)
          @path_len[i] = @path_len[src] + 1
          @prev[i] = src
          @checklist.push(i)
        end
      end
      src = @checklist.shift
    end
  end
  
  private
  def calc_initialize src, dist
    @uncheck.delete(src)
    @uncheck.push(dist)
    @path_len[src] = 0
    @prev[src] = 0
  end

  def create_neighborlist topology
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
