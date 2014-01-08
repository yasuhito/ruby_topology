#-*- coding: utf-8 -*-
require 'graphviz'

module View
  #
  # Topology controller's GUI (graphviz).
  #
  class Graphviz
    def initialize(output = './topology.png')
      @nodes = {}
      @output = File.expand_path(output)
      @graphviz = GraphViz.new(:G, use: 'neato', overlap: false, splines: true)
    end

    def update(topology)
      @nodes.clear
      add_nodes(topology)
      add_edges(topology)
      @graphviz.output(png: @output)
    end

    private

    def add_nodes(topology)
      topology.each_switch do |dpid, ports|
        if dpid.class == Fixnum
          @nodes[dpid] = @graphviz.add_nodes(dpid.to_hex, 'shape' => 'box')
        else
          s_dpid = dpid.to_s
          @nodes[s_dpid] = @graphviz.add_nodes(s_dpid, 'shape' => 'ellipse')
        end
      end
    end

    def add_edges(topology)
      topology.each_link do |each|
        node_b = @nodes[each.dpid_b]
        node_a = edges_tmp(each)
        @graphviz.add_edges node_a, node_b if node_a && node_b
      end
    end

    def edges_tmp(each)
      each_dpid = each.dpid_a
      @nodes[convert each_dpid]
    end

    def self.convert(each_dpid)
      Fixnum.instance_of?(each_dpid) ? each_dpid : each_dpid.to_s
    end
  end
end

### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
