#
# Cookbook Name:: openvnet
# Recipe:: yum_repo
#
# Copyright 2015, TIS Inc.
#
# All rights reserved - Do Not Redistribute
#

# yum
include_recipe 'yum-epel'

begin
  resources(remote_file: '/etc/yum.repos.d/openvnet.repo')
rescue Chef::Exceptions::ResourceNotFound
  remote_file '/etc/yum.repos.d/openvnet.repo' do
    source node['openvnet']['package']['repo']['file']
    owner 'root'
    group 'root'
    mode '0644'
    action :create
  end
end

begin
  resources(remote_file: '/etc/yum.repos.d/openvnet-third-party.repo')
rescue Chef::Exceptions::ResourceNotFound
  remote_file '/etc/yum.repos.d/openvnet-third-party.repo' do
    source node['openvnet']['third_party']['repo']['file']
    owner 'root'
    group 'root'
    mode '0644'
    action :create
  end
end
