#
# Cookbook Name:: vnet_part
# Recipe:: vnet_node
#
# Copyright 2015, TIS Inc.
#
# All rights reserved - Do Not Redistribute
#

extend CloudConductor::CommonHelper
extend CloudConductor::VnetPartHelper

def virtual_network_prefix(network_name)
  nwcfg = network_conf['networks'][network_name]
  nwcfg['ipv4_prefix']
end

def edge_server
  servers = server_info('vna')
  servers.first
end

def configure_interfaces
  gretap_interfaces(host_info).each do |ifname, ifcfg|
    host_name = host_info['hostname']
    remote_addr = edge_server['private_ip']
    local_addr = host_info['private_ip']
    virtual_addr = ifcfg['virtual_address']
    virtual_prefix = ifcfg['virtual_prefix']
    virtual_prefix ||= virtual_network_prefix(ifcfg['network'])

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
  end
end

configure_interfaces unless host_info['roles'].include?('vna') || host_info['roles'].include?('vnmgr')
