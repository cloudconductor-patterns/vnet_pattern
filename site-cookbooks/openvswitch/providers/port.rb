#
# Cookbook Name:: openvswitch
# Provicer:: port
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
  cmd = "ovs-vsctl add-port #{new_resource.bridge} #{new_resource.port}"

  execute cmd

  new_resource.updated_by_last_action(true)
end

action :delete do
  cmd = "ovs-vsctl del-port #{new_resource.bridge} #{new_resource.port}"

  execute cmd

  new_resource.updated_by_last_action(true)
end
