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

def already_exists?
  cmdstr = "ip addr show #{new_resource.name}"

  cmd = Mixlib::ShellOut.new(cmdstr)
  cmd.run_command
  Chef::Log.debug "gretap already_exists?: #{cmdstr}"
  Chef::Log.debug "gretap already_exists?: #{cmd.stdout}"

  begin
    cmd.error!
    true
  rescue
    false
  end
end

def create_ip_link
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
end

def delete_ip_link
  execute "ip link del #{new_resource.name}"
end

action :create do
  delete_ip_link if already_exists?
  create_ip_link
  new_resource.updated_by_last_action(true)
end

action :delete do
  if already_exists?
    delete_ip_link
    new_resource.updated_by_last_action(true)
  end
end
