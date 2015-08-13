#
# Cookbook Name:: openvnet
# Provider:: network
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
    uuid: new_resource.uuid,
    ipv4_network: new_resource.ipv4_network
  }

  params[:display_name] = new_resource.display_name if new_resource.display_name
  params[:display_name] = new_resource.uuid unless new_resource.display_name
  params[:ipv4_prefix] = new_resource.ipv4_prefix if new_resource.ipv4_prefix
  params[:domain_name] = new_resource.domain_name if new_resource.domain_name
  params[:network_mode] = new_resource.mode if new_resource.mode

  VNetAPIClient::Network.create(params)
end
