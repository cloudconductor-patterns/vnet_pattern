#
# Cookbook Name:: openvnet
# Recipe:: dataset
#
# Copyright 2015, TIS Inc.
#
# All rights reserved - Do Not Redistribute
#

node['openvnet']['dataset']['datapaths'].each do |dp_info|
  openvnet_datapath dp_info['uuid'] do
    node_id dp_info['node_id']
    display_name dp_info['display_name']
    datapath_id dp_info['dpid']
  end
end

node['openvnet']['dataset']['networks'].each do |nw_info|
  openvnet_network nw_info['uuid'] do
    display_name nw_info['display_name']
    ipv4_network nw_info['ipv4_network']
    ipv4_prefix nw_info['ipv4_prefix']
    domain_name nw_info['domain_name']
    mode nw_info['network_mode']
  end
end

node['openvnet']['dataset']['interfaces'].each do |if_info|
  openvnet_interface if_info['uuid'] do
    mode if_info['mode']
    port_name if_info['port_name']
    datapath if_info['owner_datapath_uuid']
    network if_info['network_uuid']
    mac_addr if_info['mac_address']
    ipv4_addr if_info['ipv4_address']
    ingress_filtering if_info['ingress_filtering_enabled']
    routing if_info['enable_routing']
    route_translation if_info['enable_route_translation']
  end
end
