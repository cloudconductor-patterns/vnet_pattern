#
# Cookbook Name:: openvnet
# Provider:: interface
#
# Copyright 2015, TIS.inc
#
# All rights reserved - Do Not Redistribute
#

def whyrun_supported?
  true
end

use_inline_resources

action :create do
  cmdstr = []

  cmdstr << 'vnctl interfaces add'
  cmdstr << '--uuid'
  cmdstr << new_resource.uuid

  cmdstr << "--ingress-filtering-enabled #{new_resource.ingress_filtering}" if new_resource.ingress_filtering

  cmdstr << "--enable-routing #{new_resource.routing}" if new_resource.routing

  cmdstr << "--enable-route-translation #{new_resource.route_translation}" if new_resource.route_translation

  cmdstr << "--owner-datapath-uuid #{new_resource.datapath}" if new_resource.datapath

  cmdstr << "--network-uuid #{new_resource.network}" if new_resource.network

  cmdstr << "--mac-address #{new_resource.mac_addr}" if new_resource.mac_addr

  cmdstr << "--ipv4-address #{new_resource.ipv4_addr}" if new_resource.ipv4_addr

  cmdstr << "--port-name #{new_resource.port_name}" if new_resource.port_name

  cmdstr << "--mode #{new_resource.mode}" if new_resource.mode

  execute cmdstr.join(' ')
end
