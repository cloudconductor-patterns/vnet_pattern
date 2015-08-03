#
# Cookbook Name:: vnet_part
# Recipe:: vnet_edge
#
# Copyright 2015, TIS.inc
#
# All rights reserved - Do Not Redistribute
#

extend CloudConductor::CommonHelper
extend CloudConductor::VnetPartHelper

vna_conf = host_info['vna']

registry = {
  host:  '127.0.0.1',
  port:  6379
}.with_indifferent_access

sv_vnmgr = server_info('vnmgr').first

registry['host'] = sv_vnmgr['private_ip'] if sv_vnmgr['private_ip'] != host_info['private_ip']

openvnet_vna vna_conf['id'] do
  hwaddr vna_conf['hwaddr']
  datapath_id vna_conf['datapath_id']
  registry registry
end

nodes = all_servers.reject do |_, s|
  s['roles'].include?('vna') || s['roles'].include?('vnmgr')
end

host_addr = host_info['private_ip']

nodes.each do |_hostname, node_info|
  greports = node_info['interfaces'].select do |_, dev|
    dev['type'] == 'gretap'
  end

  greports.each do |port_name, _ifcfg|
    vnet_part_gretap port_name do
      remote_addr node_info['private_ip']
      local_addr host_addr
    end

    openvswitch_port port_name do
      bridge 'br0'
    end
  end
end
