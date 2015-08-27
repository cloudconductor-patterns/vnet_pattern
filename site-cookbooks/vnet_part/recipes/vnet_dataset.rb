#
# Cookbook Name:: vnet_part
# Recipe:: vnet_dataset
#
# Copyright 2015, TIS.inc
#
# All rights reserved - Do Not Redistribute
#

extend CloudConductor::VnetPartHelper

def datapath_uuid(vna_conf)
  "dp-#{vna_conf['datapath_id'].slice(-2, 2)}"
end

def datapaths
  result = []

  server_info('vna').each do |sv_info|
    vna_conf = vna_config(sv_info['hostname'])

    cfg = {
      uuid: datapath_uuid(vna_conf),
      node_id: vna_conf['id'],
      display_name: sv_info['hostname'],
      dpid: vna_conf['datapath_id']
    }

    result << cfg
  end

  result
end

def networks
  result = []

  network_conf['networks'].each do |nw_name, nw_cfg|
    mode = 'virtual'
    mode = nw_cfg['mode'] if nw_cfg['mode']
    nw_cfg['ipv4_network'] ||= node['vnet_part']['config']['network'][mode]['addr']
    nw_cfg['ipv4_prefix'] ||= node['vnet_part']['config']['network'][mode]['mask']

    cfg = {
      uuid: "nw-#{nw_name}",
      display_name: nw_name,
      ipv4_network: nw_cfg['ipv4_network'],
      ipv4_prefix: nw_cfg['ipv4_prefix'],
      domain_name: nw_name,
      network_mode: mode
    }

    result << cfg
  end

  result
end

def vna_sv
  server_info('vna').first
end

def ingress_filtering_enabled(ifcfg)
  if ifcfg['security_groups'] && ifcfg['security_groups'].length > 0
    true
  else
    false
  end
end

def interfaces
  result = []

  dp_uuid = datapath_uuid(vna_config(vna_sv['hostname']))

  node_servers.each do |svinfo|
    gretap_interfaces(svinfo).each do |_ifname, ifcfg|
      ifcfg['uuid'] ||= "if-#{ifcfg['port_name']}"

      cfg = {
        uuid: ifcfg['uuid'],
        port_name: ifcfg['port_name'],
        owner_datapath_uuid: dp_uuid,
        network_uuid: "nw-#{ifcfg['network']}",
        mac_address: ifcfg['hwaddr'],
        ingress_filtering_enabled: ingress_filtering_enabled(ifcfg),
        ipv4_address: ifcfg['virtual_address']
      }

      result << cfg
    end
  end

  result
end

def security_groups
  sg = []

  network_conf['security_groups'].each do |sg_name, sg_cfg|
    cfg = {
      uuid: sg_name,
      display_name: sg_name,
      rules: sg_cfg['rules']
    }

    sg << cfg
  end if network_conf['security_groups']
  sg
end

def if_security_groups
  if_sg = []

  node_servers.each do |svinfo|
    gretap_interfaces(svinfo).each do |_ifname, ifcfg|
      ifcfg['uuid'] ||= "if-#{ifcfg['port_name']}"

      next unless ifcfg['security_groups'] && ifcfg['security_groups'].length > 0

      ifcfg['security_groups'].each do |sg_uuid|
        cfg = {
          interface_uuid: ifcfg['uuid'],
          security_group_uuid: sg_uuid
        }
        if_sg << cfg
      end if ifcfg['security_groups']
    end
  end

  if_sg
end

def dataset_configure
  node.set['openvnet']['dataset']['datapaths'] = datapaths
  node.set['openvnet']['dataset']['networks'] = networks
  node.set['openvnet']['dataset']['interfaces'] = interfaces

  node.set['openvnet']['dataset']['security_groups'] = security_groups
  node.set['openvnet']['dataset']['interface_security_groups'] = if_security_groups

  include_recipe 'openvnet::dataset'
end

dataset_configure if host_info['roles'].include?('vnmgr')
