#
# Cookbook Name:: openvswitch
# Recipe:: install_package
#
# Copyright 2015, TIS Inc.
#
# All rights reserved - Do Not Redistribute
#

begin
  resources(remote_file: '/etc/yum.repos.d/openvnet-third-party.repo')
rescue Chef::Exceptions::ResourceNotFound
  remote_file '/etc/yum.repos.d/openvnet-third-party.repo' do
    source 'https://raw.githubusercontent.com/axsh/openvnet/master/deployment/yum_repositories/stable/openvnet-third-party.repo'
    owner 'root'
    group 'root'
    mode '0644'
    action :create
  end
end

package 'openvswitch'

service 'openvswitch' do
  action :start
end
