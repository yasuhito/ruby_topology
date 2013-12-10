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
<<<<<<< HEAD
      @graphviz = GraphViz.new(:G, use: 'neato', overlap: false, splines: true)
=======
>>>>>>> 54b93a0a43d83e6190788d3e8bc28f2991be3131
      @nodes.clear
      add_nodes(topology)
      add_edges(topology)
      @graphviz.output(png: @output)
    end

    private

    def add_nodes(topology)
      topology.each_switch do |dpid, ports|
        @nodes[dpid] = @graphviz.add_nodes(dpid.to_hex, 'shape' => 'box')
<<<<<<< HEAD
      end
=======
<<<<<<< HEAD
			end
>>>>>>> origin/master
      topology.each_host do |host, ports|
        @nodes[host] = @graphviz.add_nodes(host, 'shape' => 'oval')
=======
>>>>>>> 54b93a0a43d83e6190788d3e8bc28f2991be3131
      end
    end

    def add_edges(topology)
      topology.each_link do |each|
        node_a, node_b = @nodes[each.dpid_a], @nodes[each.dpid_b]
        @graphviz.add_edges node_a, node_b if node_a && node_b
      end
    end
  end
end

### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
