#
# Cookbook Name:: openvnet
# Spec:: vna_spec
#
# Copyright 2015, TIS.inc
#
# All rights reserved - Do Not Redistribute
#

require_relative '../spec_helper'

describe 'openvnet::vna' do
  let(:chef_run) { ChefSpec::SoloRunner.new(step_into: %w(openvnet_vna openvswitch)) }

  before do
    chef_run.node.set['openvnet']['vna']['datapath']['datapath_id'] = '0x000000001'
    chef_run.node.set['openvnet']['vna']['datapath']['hwaddr'] = '02:01:01:00:00:01'
    chef_run.node.set['openvnet']['config']['vna']['id'] = 'test-vna1'
    chef_run.node.set['openvnet']['config']['vna']['host'] = 'localhost'
    chef_run.node.set['openvnet']['config']['vna']['public'] = '192.168.0.1'
    chef_run.node.set['openvnet']['config']['vna']['port'] = 9999

    chef_run.converge(described_recipe)
  end

  it 'create common resource' do
    expect(chef_run).to create_openvnet_common('default')
  end

  it 'create openvswitch device br0' do
    ovs_extra = <<EOS
"
set bridge     ${DEVICE} protocols=OpenFlow10,OpenFlow12,OpenFlow13 --
set bridge     ${DEVICE} other_config:disable-in-band=true --
set bridge     ${DEVICE} other-config:datapath-id=0x000000001 --
set bridge     ${DEVICE} other-config:hwaddr=02:01:01:00:00:01 --
set-fail-mode  ${DEVICE} standalone --
set-controller ${DEVICE} tcp:127.0.0.1:6633
"
EOS
    expect(chef_run).to create_openvswitch('br0').with(
      ovs_extra: ovs_extra
    )

    expect(chef_run).to create_template('/etc/sysconfig/network-scripts/ifcfg-br0').with(
      source: 'ifcfg.erb',
      cookbook: 'openvswitch',
      owner: 'root',
      group: 'root',
      mode: 0644,
      variables: {
        device: 'br0',
        onboot: 'yes',
        device_type: 'ovs',
        type: 'OVSBridge',
        bootproto: 'none',
        ipaddr: nil,
        mask: nil,
        ovs_extra: ovs_extra
      }
    )
  end

  it 'installs the openvnet-vna package' do
    expect(chef_run).to install_package('openvnet-vna')
  end

  describe 'create vna.conf file' do
    it do
      expect(chef_run).to create_template('/etc/openvnet/vna.conf').with(
        source: 'vna.conf.erb',
        cookbook: 'openvnet',
        owner: 'root',
        group: 'root',
        mode: 0644,
        variables: {
          id: 'test-vna1',
          host: 'localhost',
          public: '192.168.0.1',
          port: 9999
        }
      )
    end

    it 'at default values' do
      chef_run.node.set['openvnet']['config']['vna']['id'] = nil
      chef_run.node.set['openvnet']['config']['vna']['host'] = nil
      chef_run.node.set['openvnet']['config']['vna']['public'] = nil
      chef_run.node.set['openvnet']['config']['vna']['port'] = nil

      chef_run.converge(described_recipe)

      expect(chef_run).to create_template('/etc/openvnet/vna.conf').with(
        source: 'vna.conf.erb',
        cookbook: 'openvnet',
        owner: 'root',
        group: 'root',
        mode: 0644,
        variables: {
          id: 'vna',
          host: '127.0.0.1',
          public: nil,
          port: 9103
        }
      )
    end
  end

  it 'start the vnet-vna service' do
    expect(chef_run).to start_service('vnet-vna').with(
      provider: Chef::Provider::Service::Upstart
    )
  end
end
