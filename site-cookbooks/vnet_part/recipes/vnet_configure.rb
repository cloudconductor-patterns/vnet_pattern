#
# Cookbook Name:: vnet_part
# Recipe:: vnet_configure
#
# Copyright 2015, TIS Inc.
#
# All rights reserved - Do Not Redistribute
#

extend CloudConductor::CommonHelper
extend CloudConductor::VnetPartHelper

def platform_pattern_path
  name = platform_pattern['name']
  pattern_path(name)
end

def optional_pattern_names
  patterns = optional_patterns

  patterns = patterns.reject do |info|
    info['name'] == 'vnet_pattern'
  end

  result = patterns.map do |info|
    info['name']
  end

  result
end

def pattern_path(pattern_name)
  File.join(patterns_dir, pattern_name)
end

# load network.conf
#
def load_network_conf
  network_conf = YAML.load_file(File.join(pattern_path('vnet_pattern'), 'network.yml'))

  yml_file = File.join(platform_pattern_path, 'network.yml')
  network_conf = ::Chef::Mixin::DeepMerge.deep_merge(YAML.load_file(yml_file), network_conf) if File.exist?(yml_file)

  optional_pattern_names.each do |name|
    yml_file = File.join(pattern_path(name), 'network.yml')
    network_conf = ::Chef::Mixin::DeepMerge.deep_merge(YAML.load_file(yml_file), network_conf) if File.exist?(yml_file)
  end

  network_conf
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

def virtual_address(network_name)
  nwcfg = network_conf['networks'][network_name]

  network_addr = nwcfg['ipv4_address']
  network_addr ||= node['vnet_part']['config']['network']['virtual']['addr']

  network_prefix = nwcfg['ipv4_prefix']
  network_prefix ||= node['vnet_part']['config']['network']['virtual']['mask']

  current_addr = nwcfg['current_addr']
  current_addr ||= network_addr

  addr = IPAddr.new(current_addr).succ
  nw = IPAddr.new(network_addr).mask(network_prefix)

  if nw.include?(addr)
    set_network_current_addr(network_name, addr.to_s)
    ret = addr.to_s
  end

  ret
end

# add interface-id to nodes
#
def configure_interfaces
  node_servers.each do |svinfo|
    gretap_interfaces(svinfo).each do |ifname, ifcfg|
      host_name = svinfo['hostname']
      virtual_addr = ifcfg['virtual_address']
      virtual_addr ||= virtual_address(ifcfg['network'])

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

  key = node['vnet_part']['keys']['networks']['base']
  CloudConductor::ConsulClient::KeyValueStore.put(key, conf)

  configure_vna

  configure_interfaces
end
