#
# Cookbook Name:: vnet_part
# Recipe:: vnet_edge
#
# Copyright 2015, TIS.inc
#
# All rights reserved - Do Not Redistribute
#

extend CloudConductor::VnetPartHelper

def setup_vna
  vna_conf = vna_config(host_info['hostname'])

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
end

def create_port_name(_svinfo, ifcfg)
  val = IPAddr.new(ifcfg['virtual_address']).to_i
  "tap#{format('%08x', val).slice(-2, 2)}"
end

def create_port(svinfo, ifcfg)
  local_addr = host_info['private_ip']

  port_name = ifcfg['port_name']
  port_name ||= create_port_name(svinfo, ifcfg)

  vnet_part_gretap port_name do
    remote_addr svinfo['private_ip']
    local_addr local_addr
  end

  openvswitch_port port_name do
    bridge 'br0'
  end

  cloudconductor_server_interface "#{svinfo['hostname']}_#{ifcfg['name']}" do
    hostname svinfo['hostname']
    if_name ifcfg['name']
    port_name port_name
  end
end

def setup_interfaces
  node_servers.each do |svinfo|
    gretap_interfaces(svinfo).each do |ifname, ifcfg|
      ifcfg['name'] = ifname
      create_port(svinfo, ifcfg)
    end
  end
end

if host_info['roles'].include?('vna')
  setup_vna
  setup_interfaces
end
