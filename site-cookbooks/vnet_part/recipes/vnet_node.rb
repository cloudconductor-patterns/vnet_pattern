#
# Cookbook Name:: vnet_part
# Recipe:: vnet_node
#
# Copyright 2015, TIS Inc.
#
# All rights reserved - Do Not Redistribute
#

extend CloudConductor::VnetPartHelper

def virtual_network_prefix(ifcfg)
  ifcfg['virtual_prefix'] || network_prefix(ifcfg['network'])
end

def edge_server
  server_info('vna').first
end

gretap_interfaces(host_info).each do |ifname, ifcfg|
  host_name = host_info['hostname']
  remote_addr = edge_server['private_ip']
  local_addr = host_info['private_ip']
  virtual_addr = ifcfg['virtual_address']
  virtual_prefix = virtual_network_prefix(ifcfg)

  vnet_part_gretap ifname do
    remote_addr remote_addr
    local_addr local_addr
    virtual_addr virtual_addr
    virtual_prefix virtual_prefix
  end

  cloudconductor_server_interface "#{host_name}_#{ifname}" do
    hostname host_name
    if_name ifname
    remote_address remote_addr
    local_address local_addr
    virtual_address virtual_addr
    virtual_prefix virtual_prefix
  end
end unless host_info['roles'].include?('vna') || host_info['roles'].include?('vnmgr')
