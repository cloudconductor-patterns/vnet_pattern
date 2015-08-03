#
# Cookbook Name:: openvnet
# Recipe:: default
#
# Copyright 2015, TIS Inc.
#
# All rights reserved - Do Not Redistribute
#

include_recipe 'openvnet::vnmgr'
include_recipe 'openvnet::webapi'
include_recipe 'openvnet::vnctl'

include_recipe 'openvnet::vna'
