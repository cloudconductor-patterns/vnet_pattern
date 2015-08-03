#
# Cookbook Name:: vnet_part
# Recipe:: vnet_mgr
#
# Copyright 2015, TIS.inc
#
# All rights reserved - Do Not Redistribute
#

include_recipe 'openvnet::vnmgr'
include_recipe 'openvnet::webapi'
include_recipe 'openvnet::vnctl'
