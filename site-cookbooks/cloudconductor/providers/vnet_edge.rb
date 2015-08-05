#
# Cookbook Name:: cldoudconductor
# Provider:: vnet_edge
#
# Copyright 2015, TIS Inc.
#
# All rights reserved - Do Not Redistribute
#

def whyrun_supported?
  true
end

use_inline_resources

action :create do
  vna_conf = {
    id: new_resource.vna_id,
    hwaddr: new_resource.hwaddr,
    datapath_id: new_resource.datapath_id
  }.with_indifferent_access

  vna_conf['bridge'] = new_resource.bridge if new_resource.bridge

  key = "cloudconductor/servers/#{new_resource.hostname}"
  data = CloudConductor::ConsulClient::KeyValueStore.get(key)
  info = JSON.parse(data)

  info['vna'] = vna_conf

  CloudConductor::ConsulClient::KeyValueStore.put(key, info)

  new_resource.updated_by_last_action(true)
end
