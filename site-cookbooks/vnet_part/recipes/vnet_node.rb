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

def default_vna
  remote_server_info = server_info('vna')

  remote_server_info = remote_server_info.select do |v|
    v['vna']['id'] == host_info['vna']
  end if host_info['vna']

  remote_server_info.first
end

def find_vna(id)
  remote_server_info = server_info('vna')

  remote_server_info = remote_server_info.select do |v|
    v['vna']['id'] == id
  end

  remote_server_info.first
end

def host_interfaces(type)
  interfaces = {}

  interfaces = host_info['interfaces'].select do |_, v|
    v['type'] == type
  end if host_info['interfaces']

  interfaces
end

local_addr = host_info['private_ip']
host_name = host_info['hostname']

host_interfaces('gretap').each do |name, ifcfg|
  ifcfg['name'] = name

  remote_server_info = default_vna
  remote_server_info = find_vna(ifcfg['vna']) if ifcfg['vna']

  remote_addr = remote_server_info['private_ip']

  vnet_part_gretap ifcfg['name'] do
    remote_addr remote_addr
    local_addr local_addr
    virtual_addr ifcfg['ipaddr']
  end

  cloudconductor_server_interface ifcfg['name'] do
    hostname host_name
    ifname ifcfg['name']
    action :update
  end
end
