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

def datapaths
  result = []

  server_info('vna').each do |sv|
    vna_conf = sv['vna']

    cfg = {
      uuid: datapath_uuid(vna_conf),
      node_id: vna_conf['id'],
      display_name: nil,
      dpid: vna_conf['datapath_id']
    }

    result << cfg
  end

  result
end

def networks
  result = []

  config = node['vnet_part']['config']

  cfg = {
    uuid: 'nw-1',
    display_name: nil,
    ipv4_network: config['network']['virtual']['addr'],
    ipv4_prefix: config['network']['virtual']['mask'],
    network_mode: 'virtual'
  }

  result << cfg

  result
end

def find_vna(vna_id)
  result = server_info('vna')

  result = result.select do |v|
    v['vna']['id'] == vna_id
  end if vna_id

  result.first
end

def interfaces
  result = []

  node_servers.each do |sv|
    interfaces = sv['interfaces'].select do |_, v|
      v['type'] == 'gretap'
    end

    interfaces.each do |name, ifcfg|
      vna_conf = find_vna(sv['vna'])['vna']
      vna_conf = find_vna(ifcfg['vna'])['vna'] if ifcfg['vna']

      dp_uuid = datapath_uuid(vna_conf)

      cfg = {
        uuid: ifcfg['uuid'],
        owner_datapath_uuid: dp_uuid,
        network_uuid: 'nw-1',
        mac_address: ifcfg['hwaddr'],
        ipv4_address: ifcfg['ipaddr'].split('/')[0],
        port_name: name
      }

      result << cfg
    end
  end

  result
end

def set_security_groups
end

def dataset_configure
  node.set['openvnet']['dataset']['datapaths'] = datapaths
  node.set['openvnet']['dataset']['networks'] = networks
  node.set['openvnet']['dataset']['interfaces'] = interfaces

  set_security_groups

  include_recipe 'openvnet::dataset'
end

dataset_configure if host_info['roles'].include?('vnmgr')
