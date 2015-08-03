#
# Cookbook Name:: openvswitch
# Provider:: default
#
# Copyright 2015, TIS Inc.
#
# All rights reserved - Do Not Redistribute
#

def whyrun_supported?
  true
end

use_inline_resources

def down(dev)
  execute "ifdown #{dev}"
end

def up(dev)
  execute "ifup #{dev}"
end

def restart(dev)
  down(dev)
  up(dev)
end

action :create do
  run_context.include_recipe "openvswitch::install_#{node['openvswitch']['install_method']}"

  device_name = new_resource.name

  Chef::Log.debug "cookbook: #{new_resource.cookbook_name}"

  template "/etc/sysconfig/network-scripts/ifcfg-#{device_name}" do
    source 'ifcfg.erb'
    cookbook new_resource.cookbook
    owner 'root'
    group 'root'
    mode 0644
    variables(device: device_name,
              onboot: new_resource.onboot,
              device_type: 'ovs',
              type: new_resource.type,
              bootproto: new_resource.bootproto,
              ipaddr: new_resource.ipaddr,
              mask: new_resource.mask,
              ovs_extra: new_resource.ovs_extra)
  end

  restart device_name

  new_resource.updated_by_last_action(true)
end

action :down do
  device_name = new_resource.name
  down device_name
  new_resource.updated_by_last_action(true)
end

action :up do
  device_name = new_resource.name
  up device_name
  new_resource.updated_by_last_action(true)
end

action :restart do
  device_name = new_resource.name
  restart device_name
  new_resource.updated_by_last_action(true)
end

action :delete do
  device_name = new_resource.name

  if ::File.exist?("/etc/sysconfig/network-scripts/ifcfg-#{device_name}")
    down device_name

    file "/etc/sysconfig/network-scripts/ifcfg-#{device_name}" do
      action :delete
    end
    new_resource.updated_by_last_action(true)
  end
end
