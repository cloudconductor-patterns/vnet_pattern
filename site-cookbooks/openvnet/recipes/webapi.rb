#
# Cookbook Name:: openvnet
# Recipe:: webapi
#
# Copyright 2015, TIS Inc.
#
# All rights reserved - Do Not Redistribute
#

include_recipe 'openvnet::common'

package 'openvnet-webapi'

template '/etc/openvnet/webapi.conf' do
  source 'webapi.conf.erb'
  owner 'root'
  group 'root'
  mode 0644
  variables(host: node['openvnet']['config']['webapi']['host'],
            public: node['openvnet']['config']['webapi']['public'],
            port: node['openvnet']['config']['webapi']['port'])
end

service 'vnet-webapi' do
  provider Chef::Provider::Service::Upstart
  action :start
end
