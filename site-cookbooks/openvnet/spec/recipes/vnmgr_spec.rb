#
# Cookbook Name:: openvnet
# Spec:: vnmgr_spec
#
# Copyright 2015, TIS.inc
#
# All rights reserved - Do Not Redistribute
#

require_relative '../spec_helper'

describe 'openvnet::vnmgr' do
  let(:chef_run) { ChefSpec::SoloRunner.new }

  before do
    chef_run.node.set['openvnet']['config']['vnmgr']['host'] = 'localhost'
    chef_run.node.set['openvnet']['config']['vnmgr']['public'] = '192.168.0.1'
    chef_run.node.set['openvnet']['config']['vnmgr']['port'] = 9999

    chef_run.converge(described_recipe)
  end

  describe 'redis' do
    it 'installs redis package' do
      expect(chef_run).to install_package('redis')
    end

    it 'enable redis service' do
      expect(chef_run).to enable_service('redis')
    end

    it 'start redis service' do
      expect(chef_run).to start_service('redis')
    end
  end

  describe 'mysql' do
    it 'installs mysql package' do
      expect(chef_run).to install_package('mysql-server')
    end

    it 'enable mysqld service' do
      expect(chef_run).to enable_service('mysqld')
    end

    it 'start mysqld service' do
      expect(chef_run).to start_service('mysqld')
    end
  end

  it 'include common recipe' do
    expect(chef_run).to include_recipe('openvnet::common')
  end

  describe 'vnmgr' do
    it 'installs openvnet-vnmgr package' do
      expect(chef_run).to install_package('openvnet-vnmgr')
    end

    it 'create vnmgr.conf file' do
      expect(chef_run).to create_template('/etc/openvnet/vnmgr.conf').with(
        source: 'vnmgr.conf.erb',
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

    it 'start vnet-vnmgr service' do
      expect(chef_run).to start_service('vnet-vnmgr').with(
        provider: Chef::Provider::Service::Upstart
      )
    end
  end
end
