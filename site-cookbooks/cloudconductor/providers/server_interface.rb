#
# Cookbook Name:: cloudconductor
# Provider:: server_interface
#
# Copyright 2015, TIS Inc.
#
# All rights reserved - Do Not Redistribute
#

action :create do
  key = "cloudconductor/servers/#{new_resource.hostname}"

  info = CloudConductor::ConsulUtils::KeyValueStore.get(key)

  info['interfaces'][new_resource.ifname] = {
    uuid: new_resource.uuid,
    type: new_resource.type,
    ipaddr: new_resource.ipaddr
  }

  CloudConductor::ConsulUtils::KeyValueStore.put(key, info)

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

  info = CloudConductor::ConsulUtils::KeyValueStore.get(key)

  info['interfaces'][new_resource.ifname]['hwaddr'] = hwaddr(new_resource.ifname)

  CloudConductor::ConsulUtils::KeyValueStore.put(key, info)

  new_resource.updated_by_last_action(true)
end

action :delete do
  key = "cloudconductor/servers/#{new_resource.hostname}"
  info = CloudConductor::ConsulUtils::KeyValueStore.get(key)
  info['interfaces'].delete(new_resource.ifname)

  CloudConductor::ConsulUtils::KeyValueStore.put(key, info)

  new_resource.updated_by_last_action(true)
end
