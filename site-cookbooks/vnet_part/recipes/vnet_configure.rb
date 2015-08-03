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

# add interface-id to nodes
#
def configure_interfaces
  count = 0
  config = node['vnet_part']['config']
  virtual_addr = IPAddr.new(config['network']['virtual']['addr']).mask(config['network']['virtual']['mask'])

  node_servers.each do |info|
    count += 1
    virtual_addr = virtual_addr.succ
    id = "n#{count}"

    cloudconductor_server_interface "tap#{id}" do
      hostname info['hostname']
      uuid "if-#{id}"
      type 'gretap'
      ipaddr "#{virtual_addr.to_string}/#{config['network']['virtual']['mask']}"
      action :create
    end
  end
end

if host_info['roles'].include?('vnmgr')
  configure_vna
  configure_interfaces
end
