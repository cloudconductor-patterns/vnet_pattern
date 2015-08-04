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

action :create do
  cmdstr = []

  cmdstr << 'vnctl networks add'
  cmdstr << '--uuid'
  cmdstr << new_resource.uuid
  cmdstr << '--display-name'
  cmdstr << new_resource.display_name if new_resource.display_name
  cmdstr << new_resource.uuid unless new_resource.display_name

  cmdstr << '--ipv4-network'
  cmdstr << new_resource.ipv4_network

  cmdstr << "--ipv4-prefix #{new_resource.ipv4_prefix}" if new_resource.ipv4_prefix

  cmdstr << "--domain-name #{new_resource.domain_name}" if new_resource.domain_name

  cmdstr << "--network-mode #{new_resource.mode}" if new_resource.mode

  execute cmdstr.join(' ')
end
