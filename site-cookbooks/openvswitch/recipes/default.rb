#
# Cookbook Name:: openvswitch
# Recipe:: default
#
# Copyright 2015, TIS Inc.
#
# All rights reserved - Do Not Redistribute
#

if node['openvswitch']['bridge']
  node['openvswitch']['bridge'].each do |bridge|
    openvswitch bridge['name'] do
      type bridge['type']
      onboot bridge['onboot']
      bootproto bridge['bootproto']
      ipaddr bridge['ipaddr']
      mask bridge['mask']
      ovs_extra bridge['ovs_extra']
    end
  end
else
  openvswitch 'br0'
end
