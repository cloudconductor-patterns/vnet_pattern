#
# Cookbook Name:: openvnet
# Spec:: common_spec
#
# Copyright 2015, TIS.inc
#
# All rights reserved - Do Not Redistribute
#

require_relative '../spec_helper'

describe 'openvnet::common' do
  let(:chef_run) { ChefSpec::SoloRunner.new(step_into: %w(openvnet_common)) }

  before do
    chef_run.node.set['openvnet']['package']['repo']['file'] = 'http://remote.net/openvnet.repo'
    chef_run.node.set['openvnet']['third_party']['repo']['file'] = 'http://remote.net/openvnet-third-party.repo'
    chef_run.node.set['openvnet']['config']['registry']['host'] = '10.0.0.1'
    chef_run.node.set['openvnet']['config']['registry']['port'] = 3333
    chef_run.node.set['openvnet']['config']['database']['host'] = '10.0.0.2'
    chef_run.node.set['openvnet']['config']['database']['port'] = 4444
    chef_run.node.set['openvnet']['config']['database']['db_name'] = 'aaaa'
    chef_run.node.set['openvnet']['config']['database']['username'] = 'user'
    chef_run.node.set['openvnet']['config']['database']['password'] = 'pswd'

    chef_run.converge(described_recipe)
  end

  it 'add openvnet yum-repo' do
    expect(chef_run).to create_remote_file('/etc/yum.repos.d/openvnet.repo').with(
      source: 'http://remote.net/openvnet.repo',
      owner: 'root',
      group: 'root',
      mode: '0644'
    )
  end

  it 'add openvnet-third-party yum-repo' do
    expect(chef_run).to create_remote_file('/etc/yum.repos.d/openvnet-third-party.repo').with(
      source: 'http://remote.net/openvnet-third-party.repo',
      owner: 'root',
      group: 'root',
      mode: '0644'
    )
  end

  it 'installs the openvnet-common package' do
    expect(chef_run).to install_package('openvnet-common')
  end

  it 'create common.conf file' do
    expect(chef_run).to create_template('/etc/openvnet/common.conf').with(
      source: 'common.conf.erb',
      owner: 'root',
      group: 'root',
      mode: '0644',
      variables: {
        registry_host: '10.0.0.1',
        registry_port: 3333,
        db_host: '10.0.0.2',
        db_port: 4444,
        db_name: 'aaaa',
        db_user: 'user',
        db_pswd: 'pswd'
      }
    )
  end
end
