#
# Cookbook Name:: openvnet
# Provider:: vna
#
# Copyright 2015, TIS.inc
#
# All rights reserved - Do Not Redistribute
#

def whyrun_supported?
  true
end

use_inline_resources

action :create do
  %w(host_addr public_addr port).each do |attr|
    unless new_resource.instance_variable_get("@#{attr}")
      new_resource.instance_variable_set("@#{attr}", node['openvnet']['config']['vna'][attr])
    end
  end

  %w(redistry database).each do |attr|
    unless new_resource.instance_variable_get("@#{attr}")
      new_resource.instance_variable_set("@#{attr}", node['openvnet']['config'][attr])
    end
  end

  openvswitch new_resource.bridge do
    ovs_extra <<EOS
"
set bridge     ${DEVICE} protocols=OpenFlow10,OpenFlow12,OpenFlow13 --
set bridge     ${DEVICE} other_config:disable-in-band=true --
set bridge     ${DEVICE} other-config:datapath-id=#{new_resource.datapath_id} --
set bridge     ${DEVICE} other-config:hwaddr=#{new_resource.hwaddr} --
set-fail-mode  ${DEVICE} standalone --
set-controller ${DEVICE} tcp:127.0.0.1:6633
"
EOS
  end

  openvnet_common 'default' do
    registry new_resource.registry
    database new_resource.database
  end

  package 'openvnet-vna'

  template '/etc/openvnet/vna.conf' do
    source 'vna.conf.erb'
    owner 'root'
    group 'root'
    mode 0644
    variables(id: new_resource.vna_id,
              host: new_resource.host_addr,
              public: new_resource.public_addr,
              port: new_resource.port)
  end

  if new_resource.service_start
    service 'vnet-vna' do
      provider Chef::Provider::Service::Upstart
      action :start
    end
  end
  new_resource.updated_by_last_action(true)
end

action :start do
  service 'vnet-vna' do
    provider Chef::Provider::Service::Upstart
    action :start
  end

  new_resource.updated_by_last_action(true)
end

action :stop do
  service 'vnet-vna' do
    provider Chef::Provider::Service::Upstart
    action :stop
  end
  new_resource.updated_by_last_action(true)
end
