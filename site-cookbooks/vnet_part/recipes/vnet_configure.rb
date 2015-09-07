#
# Cookbook Name:: vnet_part
# Recipe:: vnet_configure
#
# Copyright 2015, TIS Inc.
#
# All rights reserved - Do Not Redistribute
#

extend CloudConductor::VnetPartHelper

def optional_pattern_names
  patterns = optional_patterns.reject do |info|
    info['name'] == 'vnet_pattern'
  end

  result = patterns.map do |info|
    info['name']
  end

  result
end

#
# load network.yml files
#   vnet_pattern < platform < optional
#
def load_network_yml
  new_cfg = YAML.load_file(File.join(pattern_path('vnet_pattern'), 'network.yml'))

  yml_file = File.join(platform_pattern_path, 'network.yml')
  new_cfg = ::Chef::Mixin::DeepMerge.deep_merge(YAML.load_file(yml_file), new_cfg) if File.exist?(yml_file)

  optional_pattern_names.each do |name|
    yml_file = File.join(pattern_path(name), 'network.yml')
    new_cfg = ::Chef::Mixin::DeepMerge.deep_merge(YAML.load_file(yml_file), new_cfg) if File.exist?(yml_file)
  end

  new_cfg.with_indifferent_access
end

# load network.conf
# consul < file < attributes
#
# consul key:= cloudconductor/networks/base
# file:= network.yml
#   vnet_pattern < platform < optional
# attributes vnet_part::networks
#
def load_network_conf
  current_cfg = networks_base

  new_cfg = load_network_yml

  attributes_cfg = node['vnet_part']['networks'].to_hash if node['vnet_part']['networks']
  new_cfg = ::Chef::Mixin::DeepMerge.deep_merge(attributes_cfg, new_cfg) if attributes_cfg

  ::Chef::Mixin::DeepMerge.deep_merge(new_cfg, current_cfg)
end

# add vna-id to vna server
#
def configure_vna
  count = 0

  server_info('vna').each do |sv|
    count += 1

    cloudconductor_vnet_edge sv['hostname'] do
      vna_id "vna#{count}"
      hwaddr "02:00:01:01:00:#{format('%02x', count)}"
      datapath_id "0x000200010100#{format('%02x', count)}"
    end
  end
end

def next_vaddr(network_name)
  network_addr = network_address(network_name)
  network_prefix = network_prefix(network_name)
  current_addr = current_address(network_name)

  addr = IPAddr.new(current_addr).succ
  nw = IPAddr.new(network_addr).mask(network_prefix)

  if nw.include?(addr)
    set_network_current_addr(network_name, addr.to_s)
    ret = addr.to_s
  end

  ret
end

def virtual_address(ifcfg)
  ifcfg['virtual_address'] || next_vaddr(ifcfg['network'])
end

# add interface-id to nodes
#
def configure_interfaces
  node_servers.each do |svinfo|
    gretap_interfaces(svinfo).each do |ifname, ifcfg|
      host_name = svinfo['hostname']
      virtual_addr = virtual_address(ifcfg)

      cloudconductor_server_interface "#{host_name}_#{ifname}" do
        action :create
        hostname host_name
        if_name ifname
        network ifcfg['network']
        security_groups ifcfg['security_groups']
        virtual_address virtual_addr
      end
    end
  end
end

if host_info['roles'].include?('vnmgr')
  conf = load_network_conf
  node.set['vnet_part']['networks'] = conf

  configure_vna

  configure_interfaces

  key = node['vnet_part']['keys']['networks']['base']
  data = {
    cloudconductor: {
      networks: {
        base: node['vnet_part']['networks']
      }
    }
  }
  CloudConductor::ConsulClient::KeyValueStore.put(key, data)
end
