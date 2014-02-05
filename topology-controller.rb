# -*- coding: utf-8 -*-
$LOAD_PATH.unshift File.expand_path(File.join File.dirname(__FILE__), 'lib')

require 'rubygems'
require 'bundler/setup'
require 'command-line'
require 'topology'
require 'trema'
require 'trema-extensions/port'

#
# This controller collects network topology information using LLDP.
#
class TopologyController < Controller
  periodic_timer_event :flood_lldp_frames, 3

  def start
    @command_line = CommandLine.new
    @command_line.parse(ARGV.dup)
    @topology = Topology.new(@command_line.view)
    @host_list = {}
  end

  def switch_ready(dpid)
    send_message dpid, FeaturesRequest.new
  end

  def features_reply(dpid, features_reply)
    features_reply.physical_ports.select(&:up?).each do |each|
      @topology.add_port each
    end
  end

  def switch_disconnected(dpid)
    @topology.delete_switch dpid
  end

  def port_status(dpid, port_status)
    updated_port = port_status.port
    return if updated_port.local?
    @topology.update_port updated_port
  end

  def packet_in(dpid, packet_in)
    if packet_in.lldp?
      @topology.add_link_by dpid, packet_in
    elsif packet_in.ipv4?
      return if packet_in.ipv4_saddr.to_s == '0.0.0.0'
      if @host_list[packet_in.ipv4_saddr.to_s].nil?
        @host_list[packet_in.ipv4_saddr.to_s] = packet_in.macsa.to_s
        @topology.add_host dpid, packet_in
      end
    end
  end

  private

  def add_flow(dpid, message, port, in_port)
    send_flow_mod_add(
      dpid,
      hard_timeout: 100,
      match: Match.new(
      in_port: in_port,
      nw_src: message.ipv4_saddr,
      nw_dst: message.ipv4_daddr
      ),
      actions: Trema::SendOutPort.new(port)
    )
  end

  def flood_lldp_frames
    @topology.each_switch do |dpid, ports|
      send_lldp dpid, ports
    end
  end

  def send_lldp(dpid, ports)
    ports.each do |each|
      port_number = each.number
      send_packet_out(
        dpid,
        actions: SendOutPort.new(port_number),
        data: lldp_binary_string(dpid, port_number)
      )
    end
  end

  def lldp_binary_string(dpid, port_number)
    destination_mac = @command_line.destination_mac
    if destination_mac
      Pio::Lldp.new(dpid: dpid,
                    port_number: port_number,
                    destination_mac: destination_mac.value).to_binary
    else
      Pio::Lldp.new(dpid: dpid, port_number: port_number).to_binary
    end
  end

end

### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
