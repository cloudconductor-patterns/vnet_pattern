#
# Cookbook Name:: openvswitch
# Spec:: default_spec
#
# Copyright 2015, TIS.inc
#
# All rights reserved - Do Not Redistribute
#

require_relative '../spec_helper'

describe 'openvswitch::default' do
  let(:chef_run) { ChefSpec::SoloRunner.new(step_into: %w(openvswitch)) }

  before do
    chef_run.converge(described_recipe)
  end

  it 'create OVSBridge' do
    expect(chef_run).to create_openvswitch('br0')

    expect(chef_run).to include_recipe('openvswitch::install_package')

    expect(chef_run).to create_template('/etc/sysconfig/network-scripts/ifcfg-br0')

    expect(chef_run).to run_execute('ifup br0')
  end

  describe 'create ' do
    before do
      chef_run.node.set['openvswitch']['bridge'] = [
        {
          name: 'br001',
          ipaddr: '10.100.0.1,',
          mask: '255.255.255.0'
        }
      ]

      chef_run.converge(described_recipe)
    end

    it do
      expect(chef_run).to create_openvswitch('br001').with(
        ipaddr: '10.100.0.1,',
        mask: '255.255.255.0'
      )
    end
  end
end
