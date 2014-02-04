# -*- coding: utf-8 -*-
require 'graphviz'

module View
  #
  # Topology controller's GUI (graphviz).
  #
  class Graphviz
    # Graphviz options
    LABELDISTANCE = '1.4'
    FONTSIZE = '10'
    LABELFONTCOLOR = 'black'

    def initialize(output = './topology.png', is_port_label = false)
      @nodes = {}
      @output = File.expand_path(output)
      @is_port_label = is_port_label
    end

    def update(topology)
      @graphviz = GraphViz.new(:G, use: 'neato', overlap: false, splines: true)
      @nodes.clear
      add_nodes(topology)
      add_edges(topology)
      @graphviz.output(png: @output)
    end

    private

    def add_nodes(topology)
      topology.each_switch do |dpid, ports|
        @nodes[dpid] = @graphviz.add_nodes(dpid.to_hex, 'shape' => 'box')
      end
      topology.each_host do |host_ip|
        @nodes[host_ip] = @graphviz.add_nodes(host_ip, 'shape' => 'ellipse')
      end
    end

    def add_edges(topology)
      topology.each_link do |each|
        node_a, node_b = @nodes[each.dpid_a], @nodes[each.dpid_b]
        if node_a && node_b
          edge_label_option = get_edge_label_option(each)
          write_edges(node_a, node_b, edge_label_option)
        end
      end
    end

    def write_edges(node_a, node_b, edge_label_option)
      if @is_port_label
        @graphviz.add_edges(node_a, node_b, edge_label_option)
      else
        @graphviz.add_edges(node_a, node_b)
      end
    end

    def get_edge_label_option(link)
      {
        'headlabel' => link.port_b,
        'taillabel' => link.port_a,
        'labeldistance' => LABELDISTANCE,
        'fontsize' => FONTSIZE,
        'labelfontcolor' => LABELFONTCOLOR
      }
    end
  end
end

### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
