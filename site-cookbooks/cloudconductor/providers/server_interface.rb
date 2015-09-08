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

def key
  "cloudconductor/networks/#{new_resource.hostname}/#{new_resource.if_name}"
end

action :create do
  current_info = {}
  data = CloudConductor::ConsulClient::KeyValueStore.get(key)
  current_info = JSON.parse(data) if data && data.length > 0

  new_info = {}
  new_info['type'] = new_resource.type if new_resource.type
  new_info['network'] = new_resource.network if new_resource.network
  new_info['security_groups'] = new_resource.security_groups if new_resource.security_groups
  new_info['remote_address'] = new_resource.remote_address if new_resource.remote_address
  new_info['local_address'] = new_resource.local_address if new_resource.local_address
  new_info['virtual_address'] = new_resource.virtual_address if new_resource.virtual_address
  new_info['virtual_prefix'] = new_resource.virtual_prefix if new_resource.virtual_prefix
  new_info['uuid'] = new_resource.uuid if new_resource.uuid
  new_info['hwaddr'] = new_resource.hwaddr if new_resource.hwaddr
  new_info['hwaddr'] = hwaddr(new_resource.if_name) unless new_resource.hwaddr if new_resource.remote_address
  new_info['port_name'] = new_resource.port_name if new_resource.port_name

  new_info = {
    'cloudconductor' => {
      'networks' => {
        new_resource.hostname => {
          new_resource.if_name => new_info
        }
      }
    }
  }.with_indifferent_access

  info = ::Chef::Mixin::DeepMerge.deep_merge(new_info, clone(current_info))

  unless info == current_info
    CloudConductor::ConsulClient::KeyValueStore.put(key, info)
    new_resource.updated_by_last_action(true)
  end
end

def clone(h)
  JSON.parse(JSON.generate(h)).with_indifferent_access
end

def hwaddr(dev_name)
  cmdstr = "echo -n $(ip link show #{dev_name} | awk '/link\\/ether/ { print $2 }')"

  cmd = Mixlib::ShellOut.new(cmdstr)
  cmd.run_command

  begin
    cmd.error!
    ret = cmd.stdout
  rescue
    Chef::Log.debug "server_nterface_hwaddr: #{cmdstr}"
    Chef::Log.debug "server_nterface_hwaddr: #{cmd.stdout}"
  end

  ret
end

action :delete do
  CloudConductor::ConsulUtils::KeyValueStore.delete(key)

  new_resource.updated_by_last_action(true)
end
