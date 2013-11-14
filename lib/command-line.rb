# -*- coding: utf-8 -*-
require 'rubygems'

require 'gli'
require 'view/text'

#
# command-line options passed to topology-controller.rb
#
class CommandLine
  include GLI::App

  attr_reader :view
  attr_reader :destination_mac
  attr_reader :port_number

  def initialize
    @port_number = false
    @view = View::Text.new
  end

  def parse(argv)
    program_desc 'Topology discovery controller'
    parse_set_flag_and_switch
    define_text_command
    define_graphviz_command
    run argv
  end

  private

  def parse_set_flag_and_switch
    set_destination_mac_flag
    set_port_number_switch
  end

  def set_destination_mac_flag
    flag [:d, :destination_mac]
    pre do |global_options, command, options, args|
      destination_mac = global_options[:destination_mac]
      @destination_mac = Mac.new(destination_mac) if destination_mac
      true
    end
  end

  def set_port_number_switch
    desc 'Show port numbers of edges in Graphviz mode'
    switch [:p, :port_number]
    pre do |global_options, command, options, args|
      port_number = global_options[:port_number]
      @port_number = true if port_number
      true
    end
  end

  def define_text_command
    default_command :text
    desc 'Displays topology information (text mode)'
    command :text do |cmd|
      cmd.action(&method(:create_text_view))
    end
  end

  def define_graphviz_command
    desc 'Displays topology information (Graphviz mode)'
    arg_name 'output_file'
    command :graphviz do |cmd|
      cmd.action(&method(:create_graphviz_view))
    end
  end

  private

  def create_text_view(_global_options, _options, _args)
    @view = View::Text.new
  end

  def create_graphviz_view(_global_options, _options, args)
    require 'view/graphviz'
    if args.empty?
      @view = View::Graphviz.new('./topology.png', @port_number)
    else
      @view = View::Graphviz.new(args[0], @port_number)
    end
  end
end

### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
