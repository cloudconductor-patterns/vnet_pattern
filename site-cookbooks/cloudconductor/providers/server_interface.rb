#
# Cookbook Name:: cloudconductor
# Provider:: server_interface
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
  key = "cloudconductor/servers/#{new_resource.hostname}"

  data = CloudConductor::ConsulClient::KeyValueStore.get(key)
  info = JSON.parse(data)

  interfaces = {}
  interfaces = info['interfaces'] if info['interfaces']

  interfaces[new_resource.ifname] = {
    uuid: new_resource.uuid,
    type: new_resource.type,
    ipaddr: new_resource.ipaddr
  }

  info['interfaces'] = interfaces

  CloudConductor::ConsulClient::KeyValueStore.put(key, info)

  new_resource.updated_by_last_action(true)
end

def hwaddr(dev_name)
  cmdstr = "ip link show #{dev_name} | awk '/link\/ether/ { print $2 }'"

  cmd = Mixlib::ShellOut.new(cmdstr)
  cmd.run_command
  Chef::Log.debug "server_nterface_hwaddr: #{cmdstr}"
  Chef::Log.debug "server_nterface_hwaddr: #{cmd.stdout}"

  cmd.stdout
end

action :update do
  key = "cloudconductor/servers/#{new_resource.hostname}"

  data = CloudConductor::ConsulClient::KeyValueStore.get(key)
  info = JSON.parse(data)

  info['interfaces'][new_resource.ifname]['hwaddr'] = hwaddr(new_resource.ifname)

  CloudConductor::ConsulClient::KeyValueStore.put(key, info)

  new_resource.updated_by_last_action(true)
end

action :delete do
  key = "cloudconductor/servers/#{new_resource.hostname}"
  data = CloudConductor::ConsulUtils::KeyValueStore.get(key)
  info = JSON.parse(data)
  info['interfaces'].delete(new_resource.ifname)

  CloudConductor::ConsulUtils::KeyValueStore.put(key, info)

  new_resource.updated_by_last_action(true)
end
