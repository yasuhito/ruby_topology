# -*- coding: utf-8 -*-
require 'graphviz'

module View
  #
  # Topology controller's GUI (graphviz).
  #
  class Graphviz
    def initialize(output = './topology.png')
      @nodes = {}
      @hosts = {}
      @num_host = 0
      @output = File.expand_path(output)
      @graphviz = GraphViz.new(:G, use: 'neato', overlap: false, splines: true)
    end

    def update(topology)
      @nodes.clear
      @hosts.clear
      @num_host = 0
      add_nodes(topology)
      add_edges(topology)
      add_hosts(topology)
      @graphviz.output(png: @output)
    end

    private

    def add_nodes(topology)
      topology.each_switch do |dpid, ports|
        @nodes[dpid] = @graphviz.add_nodes(dpid.to_hex, 'shape' => 'box')
      end
    end

    def add_edges(topology)
      topology.each_link do |each|
        node_a, node_b = @nodes[each.dpid_a], @nodes[each.dpid_b]
        @graphviz.add_edges node_a, node_b if node_a && node_b
      end
    end

    def add_hosts(topology)
      topology.each_host do |each|
        @hosts[@num_host] = @graphviz.add_nodes(each.ip_b, 'shape' => 'box')
        node_a, node_b = @nodes[each.dpid_a], @hosts[@num_host]
        @graphviz.add_edges node_a, node_b if node_a && node_b
        @num_host += 1
      end
    end
  end
end

### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
