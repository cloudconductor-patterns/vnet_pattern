#
# Cookbook Name:: openvnet
# Recipe:: vna
#
# Copyright 2015, TIS.inc
#
# All rights reserved - Do Not Redistribute
#

openvnet_vna node['openvnet']['config']['vna']['id'] do
  bridge 'br0'
  datapath_id node['openvnet']['vna']['datapath']['datapath_id']
  hwaddr node['openvnet']['vna']['datapath']['hwaddr']
  host_addr node['openvnet']['config']['vna']['host_addr']
  public_addr node['openvnet']['config']['vna']['public_addr']
  port node['openvnet']['config']['vna']['port']
  registry node['openvnet']['config']['registry']
  database node['openvnet']['config']['database']
end
