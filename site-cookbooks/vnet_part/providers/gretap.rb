#
# Cookbook Name:: vnet_part
# Provider:: gretap
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
  cmd = []

  cmd << 'ip link add'
  cmd << new_resource.name
  cmd << 'type gretap'
  cmd << 'remote'
  cmd << new_resource.remote_addr

  cmd << "local #{new_resource.local_addr}" if new_resource.local_addr

  execute cmd.join(' ')

  if new_resource.virtual_addr
    execute "ip addr add #{new_resource.virtual_addr} dev #{new_resource.name}"
  end

  execute "ip link set #{new_resource.name} up"

  execute "ip link set #{new_resource.name} mtu 1450"

  new_resource.updated_by_last_action(true)
end

action :delete do
  execute "ip link del #{new_resource.name}"

  new_resource.updated_by_last_action(true)
end
