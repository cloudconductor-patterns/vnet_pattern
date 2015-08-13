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
  require 'vnet_api_client'

  VNetAPIClient.uri = "http://#{node['openvnet']['config']['webapi']['host']}:#{node['openvnet']['config']['webapi']['port']}"

  params = {
    uuid: new_resource.uuid
  }
  params[:ingress_filtering_enabled] = new_resource.ingress_filtering if new_resource.ingress_filtering
  params[:enable_routing] = new_resource.routing if new_resource.routing
  params[:enable_route_translation] = new_resource.route_translation if new_resource.route_translation
  params[:owner_datapath_uuid] = new_resource.datapath if new_resource.datapath
  params[:network_uuid] = new_resource.network if new_resource.network
  params[:mac_address] = new_resource.mac_addr if new_resource.mac_addr
  params[:ipv4_address] = new_resource.ipv4_addr if new_resource.ipv4_addr
  params[:port_name] = new_resource.port_name if new_resource.port_name
  params[:mode] = new_resource.mode if new_resource.mode

  VNetAPIClient::Interface.create(params)
end
