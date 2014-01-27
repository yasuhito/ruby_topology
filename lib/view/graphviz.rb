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
      graphviz = GraphViz.new(:G, use: 'neato', overlap: false, splines: true)
      nodes = add_nodes(graphviz, topology)
      add_edges(graphviz, topology, nodes)
      add_hosts(graphviz, topology, nodes)
      graphviz.output(png: @output)
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

    def add_hosts(graphviz, topology, switch)
      host = {}
      topology.each_host do |each|
        host[each.ipaddr2.to_s] = graphviz.add_nodes(each.ipaddr2.to_s)
      end
      host
      topology.each_host do |each|
        if switch[each.dpid1]
          graphviz.add_edges switch[each.dpid1], host[each.ipaddr2.to_s]
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
