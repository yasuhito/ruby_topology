# -*- coding: utf-8 -*-
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

    def add_nodes(graphviz, topology)
      nodes = {}
      topology.each_switch do |dpid, ports|
        nodes[dpid] = graphviz.add_nodes(dpid.to_hex, 'shape' => 'box')
      end
      topology.each_host do |host|
        nodes[host] = graphviz.add_nodes(host, 'shape' => 'ellipse')
      end
      nodes
    end

    def add_edges(graphviz, topology, nodes)
      topology.each_link do |each|
        if nodes[each.dpid1] && nodes[each.dpid2]
          graphviz.add_edges nodes[each.dpid1], nodes[each.dpid2]
        end
      end
    end
  end
end

### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
