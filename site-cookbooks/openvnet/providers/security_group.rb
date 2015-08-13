#
# Cookbook Name:: openvnet
# Provider:: security_group
#
# Copyright 2015, TIS.inc
#
# All rights reserved - Do Not Redistribute
#

def whyrun_supported?
  true
end

use_inline_resources

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
    display_name: new_resource.display_name
  }

  rules = new_resource.rules
  rules = rules.join(',') if rules.is_a?(Array)

  params[:display_name] ||= new_resource.uuid
  params[:uuid] = new_resource.uuid
  params[:rules] = rules

  VNetAPIClient::SecurityGroup.create(params)

  new_resource.interfaces.each do |if_uuid|
    VNetAPIClient::SecurityGroup.add_interface(new_resource.uuid, if_uuid)
  end if new_resource.interfaces
end
