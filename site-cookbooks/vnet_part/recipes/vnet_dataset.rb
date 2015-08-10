#
# Cookbook Name:: vnet_part
# Recipe:: vnet_dataset
#
# Copyright 2015, TIS.inc
#
# All rights reserved - Do Not Redistribute
#

extend CloudConductor::CommonHelper
extend CloudConductor::VnetPartHelper

def datapath_uuid(vna_conf)
  "dp-#{vna_conf['datapath_id'].slice(-2, 2)}"
end

def set_datapaths
  server_info('vna').each do |sv|
    vna_conf = sv['vna']

    openvnet_datapath datapath_uuid(vna_conf) do
      datapath_id vna_conf['datapath_id']
      node_id vna_conf['id']
    end
  end
end

def set_networks
  config = node['vnet_part']['config']

  openvnet_network 'nw-1' do
    ipv4_network config['network']['virtual']['addr']
    ipv4_prefix config['network']['virtual']['mask']
    mode 'virtual'
  end
end

def find_vna(vna_id)
  result = server_info('vna')

  result = result.select do |v|
    v['vna']['id'] == vna_id
  end if vna_id

  result.first
end

def set_interfaces
  node_servers.each do |sv|
    interfaces = sv['interfaces'].select do |_, v|
      v['type'] == 'gretap'
    end

    interfaces.each do |name, ifcfg|
      vna_conf = find_vna(sv['vna'])['vna']
      vna_conf = find_vna(ifcfg['vna'])['vna'] if ifcfg['vna']

      dp_uuid = datapath_uuid(vna_conf)

      openvnet_interface ifcfg['uuid'] do
        datapath dp_uuid
        network 'nw-1'
        mac_addr ifcfg['hwaddr']
        ipv4_addr ifcfg['ipaddr'].split('/')[0]
        port_name name
      end
    end
  end
end

def set_security_groups
end

def dataset_configure
  set_datapaths
  set_networks
  set_interfaces

  set_security_groups
end

dataset_configure if host_info['roles'].include?('vnmgr')
