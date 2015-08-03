#
# Cookbook Name:: openvnet
# Recipe:: common
#
# Copyright 2015, TIS Inc.
#
# All rights reserved - Do Not Redistribute
#

openvnet_common 'default' do
  registry node['openvnet']['config']['registry']
  database node['openvnet']['config']['database']
end
