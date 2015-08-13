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

def key
  "cloudconductor/networks/#{new_resource.hostname}/vna"
end

action :create do
  current_info = {}
  data = CloudConductor::ConsulClient::KeyValueStore.get(key)
  current_info = JSON.parse(data) if data

  new_info = {
    id: new_resource.vna_id,
    hwaddr: new_resource.hwaddr,
    datapath_id: new_resource.datapath_id
  }.with_indifferent_access

  new_info['bridge'] = new_resource.bridge if new_resource.bridge

  info = current_info.merge(new_info)

  unless info == current_info
    CloudConductor::ConsulClient::KeyValueStore.put(key, info)
    new_resource.updated_by_last_action(true)
  end
end
