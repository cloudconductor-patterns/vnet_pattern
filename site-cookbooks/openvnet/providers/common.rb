#
# Cookbook Name:: openvnet
# Provider:: common
#
# Copyright 2015, TIS Inc.
#
# All rights reserved - Do Not Redistribute
#

def whyrun_supported?
  true
end

use_inline_resources

action :create do
  run_context.include_recipe 'openvnet::yum_repo'

  # package 'openvnet'
  package 'openvnet-common'

  template '/etc/openvnet/common.conf' do
    source 'common.conf.erb'
    cookbook new_resource.cookbook
    owner 'root'
    group 'root'
    mode '0644'
    variables(registry_host: new_resource.registry['host'],
              registry_port: new_resource.registry['port'],
              db_host: new_resource.database['host'],
              db_port: new_resource.database['port'],
              db_name: new_resource.database['db_name'],
              db_user: new_resource.database['username'],
              db_pswd: new_resource.database['password'])
  end

  new_resource.updated_by_last_action(true)
end
