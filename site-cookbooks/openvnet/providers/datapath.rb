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

def webapi_uri
  config = node['openvnet']['config']

  uri = "#{config['vnctl']['webapi_protocol']}://"
  uri << config['vnctl']['webapi_uri']
  uri << ':'
  uri << config['vnctl']['webapi_port']
end

action :create do
  require 'vnet_api_client'

  VNetAPIClient.uri = webapi_uri

  params = {
    uuid: new_resource.uuid,
    dpid: new_resource.datapath_id,
    node_id: new_resource.node_id
  }
  params[:display_name] = new_resource.display_name if new_resource.display_name
  params[:display_name] = new_resource.uuid unless new_resource.display_name

  VNetAPIClient::Datapath.create(params)
end
