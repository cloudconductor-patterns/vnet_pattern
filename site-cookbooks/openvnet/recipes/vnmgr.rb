#
# Cookbook Name:: openvnet
# Recipe:: vnmgr
#
# Copyright 2015, TIS.inc
#
# All rights reserved - Do Not Redistribute
#

include_recipe 'openvnet::common'

# redis
package 'redis'

service 'redis' do
  action [:enable, :start]
end

# database
package 'mysql-server'

service 'mysqld' do
  action [:enable, :start]
end

# execute db:create
# include_recipe 'database::mysql'

mysql2_chef_gem 'default' do
  action :install
end

mysql_database node['openvnet']['config']['database']['db_name'] do
  connection(
    host: node['openvnet']['config']['database']['host'],
    port: node['openvnet']['config']['database']['port'],
    username: node['openvnet']['config']['database']['username'],
    password: node['openvnet']['config']['database']['password']
  )
  action :create
end

# vnmgr
package 'openvnet-vnmgr'
package 'openvnet-ruby'

# execute db:init
execute 'bundle exec rake db:init' do
  cwd '/opt/axsh/openvnet/vnet/'
end

# vnmgr.conf
template '/etc/openvnet/vnmgr.conf' do
  source 'vnmgr.conf.erb'
  owner 'root'
  group 'root'
  mode 0644
  variables(host: node['openvnet']['config']['vnmgr']['host'],
            public: node['openvnet']['config']['vnmgr']['public'],
            port: node['openvnet']['config']['vnmgr']['port'])
end

service 'vnet-vnmgr' do
  provider Chef::Provider::Service::Upstart
  action :start
end
