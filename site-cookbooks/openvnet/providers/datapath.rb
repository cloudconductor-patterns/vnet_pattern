#
# Cookbook Name:: openvnet
# Provider:: datapath
#
# Copyright 2015, TIS.inc
#
# All rights reserved - Do Not Redistribute
#

def whyrun_supported?
  true
end

use_inline_resources

def cmd_exists?(cmd_name)
  cmdstr = "which #{cmd_name}"

  cmd = Mixlib::ShellOut.new(cmdstr)
  cmd.run_command

  Chef::Log.debug "datapath cmd_exists?: #{cmdstr}"
  Chef::Log.debug "datapath cmd_exists?: #{cmd.stdout}"

  begin
    cmd.error!
    true
  rescue
    false
  end
end

action :create do
  cmdstr = []
  cmdstr << 'vnctl datapaths add'

  cmdstr << '--uuid'
  cmdstr << new_resource.uuid

  cmdstr << '--display-name'
  cmdstr << new_resource.display_name if new_resource.display_name
  cmdstr << new_resource.uuid unless new_resource.display_name

  cmdstr << '--dpid'
  cmdstr << new_resource.datapath_id

  cmdstr << '--node-id'
  cmdstr << new_resource.node_id

  execute cmdstr.join(' ')
end
