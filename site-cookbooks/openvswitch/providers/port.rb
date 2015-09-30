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

def already_exist?
  cmdstr = "ovs-vsctl show | grep #{new_resource.port}"

  cmd = Mixlib::ShellOut.new(cmdstr)
  cmd.run_command

  begin
    cmd.error!
    true
  rescue
    false
  end
end

def delete
  cmd = "ovs-vsctl del-port #{new_resource.bridge} #{new_resource.port}"
  execute cmd
end

action :create do
  delete if already_exist?

  cmd = "ovs-vsctl add-port #{new_resource.bridge} #{new_resource.port}"
  execute cmd

  new_resource.updated_by_last_action(true)
end

action :delete do
  delete

  new_resource.updated_by_last_action(true)
end
