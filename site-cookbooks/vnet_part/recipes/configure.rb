#
# Cookbook Name:: vnet_part
# Recipe:: configure
#
# Copyright 2015, TIS.inc
#
# All rights reserved - Do Not Redistribute
#

include_recipe 'vnet_part::vnet_mgr'

include_recipe 'vnet_part::vnet_edge'
