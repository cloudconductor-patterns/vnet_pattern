#
# Cookbook Name:: openvnet
# Spec:: webapi_spec
#
# Copyright 2015, TIS.inc
#
# All rights reserved - Do Not Redistribute
#

require_relative '../spec_helper'

describe 'openvnet::webapi' do
  let(:chef_run) { ChefSpec::SoloRunner.new }

  before do
    chef_run.node.set['openvnet']['config']['webapi']['host'] = 'localhost'
    chef_run.node.set['openvnet']['config']['webapi']['public'] = '192.168.0.1'
    chef_run.node.set['openvnet']['config']['webapi']['port'] = 9999

    chef_run.converge(described_recipe)
  end

  it 'include common recipe' do
    expect(chef_run).to include_recipe('openvnet::common')
  end

  describe 'webapi' do
    it 'installs openvnet-webapi package' do
      expect(chef_run).to install_package('openvnet-webapi')
    end

    it 'create webapi.conf file' do
      expect(chef_run).to create_template('/etc/openvnet/webapi.conf').with(
        source: 'webapi.conf.erb',
        owner: 'root',
        group: 'root',
        mode: 0644,
        variables: {
          host: 'localhost',
          public: '192.168.0.1',
          port: 9999
        }
      )
    end

    it 'start vnet-webapi service' do
      expect(chef_run).to start_service('vnet-webapi').with(
        provider: Chef::Provider::Service::Upstart
      )
    end
  end
end
