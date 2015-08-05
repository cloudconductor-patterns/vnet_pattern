#
# Cookbook Name:: vnet_part
# Spec:: recipies/vnet_node_spec
#
# Copyright 2015, TIS Inc.
#
# All rights reserved - Do Not Redistribute
#

require_relative '../spec_helper'
require_relative '../../../cloudconductor/libraries/consul_helper.rb'
require_relative '../../../cloudconductor/libraries/consul_helper_kv.rb'

describe 'vnet_part::vnet_node' do
  let(:chef_run) { ChefSpec::SoloRunner.new(step_into: %w(vnet_part_gretap cloudconductor_server_interface)) }

  before do
    chef_run.node.set['cloudconductor']['servers'] = {
      edge1: {
        private_ip: '192.168.0.1',
        public_ip: '',
        roles: %w(vna vnmgr),
        vna: {
          id: 'vna1'
        }
      },
      edge2: {
        private_ip: '192.168.0.2',
        public_ip: '',
        roles: ['vna'],
        vna: {
          id: 'vna2'
        }
      },
      node1: {
        private_ip: '192.168.0.10',
        roles: ['web'],
        interfaces: {
          tap1: {
            ipaddr: '10.1.0.1/24',
            type: 'gretap'
          },
          tap2: {
            type: 'bridge'
          }
        }
      },
      node2: {
        private_ip: '192.168.0.20',
        roles: ['ap'],
        interfaces: {
          tap1: {
            ipaddr: '10.1.0.2/24',
            type: 'bridge'
          },
          tap2: {
            type: 'gretap'
          }
        }
      },
      node3: {
        private_ip: '192.168.0.30',
        roles: ['db'],
        vna: 'vna2',
        interfaces: {
          tap1: {
            ipaddr: '10.1.0.3/24',
            type: 'gretap'
          }
        }
      },
      node4: {
        private_ip: '192.168.0.40',
        roles: [''],
        vna: 'vna1',
        interfaces: {
          tap1: {
            ipaddr: '10.1.0.4/24',
            type: 'gretap'
          },
          tap2: {
            ipaddr: '10.2.0.4/24',
            vna: 'vna2',
            type: 'gretap'
          }
        }
      }
    }

    # chef_run.node.set['ipaddress'] = '192.168.0.10'
    chef_run.node.set['vnet_part']['node_ref'] = 'node1'

    allow(CloudConductor::ConsulClient::KeyValueStore).to receive(:get).and_return('{"interfaces": {"tap1": {}, "tap2": {}}}')
    expect(CloudConductor::ConsulClient::KeyValueStore).to receive(:put).at_least(:once)

    chef_run.converge(described_recipe)
  end

  def create_gretap(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:vnet_part_gretap, :create, resource_name)
  end

  it 'create gretap and add ipaddr' do
    expect(chef_run).to create_gretap('tap1').with(
      remote_addr: '192.168.0.1',
      local_addr: '192.168.0.10',
      virtual_addr: '10.1.0.1/24'
    )
    expect(chef_run).to_not create_gretap('tap2')

    expect(chef_run).to run_execute('ip link add tap1 type gretap remote 192.168.0.1 local 192.168.0.10')
    expect(chef_run).to run_execute('ip addr add 10.1.0.1/24 dev tap1')
    expect(chef_run).to run_execute('ip link set tap1 up')
  end

  it 'create gretap not has ipaddr' do
    chef_run.node.set['vnet_part']['node_ref'] = 'node2'
    chef_run.converge(described_recipe)

    expect(chef_run).to_not create_gretap('tap1')

    expect(chef_run).to create_gretap('tap2').with(
      remote_addr: '192.168.0.1',
      local_addr: '192.168.0.20',
      virtual_addr: nil
    )

    expect(chef_run).to run_execute('ip link add tap2 type gretap remote 192.168.0.1 local 192.168.0.20')
    expect(chef_run).to_not run_execute('ip addr add 10.1.0.2/24 dev tap2')
    expect(chef_run).to run_execute('ip link set tap2 up')
  end

  it 'create gretap connect to 2nd vna' do
    chef_run.node.set['vnet_part']['node_ref'] = 'node3'
    chef_run.converge(described_recipe)

    expect(chef_run).to create_gretap('tap1').with(
      remote_addr: '192.168.0.2',
      local_addr: '192.168.0.30',
      virtual_addr: '10.1.0.3/24'
    )

    expect(chef_run).to run_execute('ip link add tap1 type gretap remote 192.168.0.2 local 192.168.0.30')
  end

  it 'create gretap connect to 1st and 2nd vna' do
    chef_run.node.set['vnet_part']['node_ref'] = 'node4'
    chef_run.converge(described_recipe)

    expect(chef_run).to create_gretap('tap1').with(
      remote_addr: '192.168.0.1',
      local_addr: '192.168.0.40',
      virtual_addr: '10.1.0.4/24'
    )

    expect(chef_run).to create_gretap('tap2').with(
      remote_addr: '192.168.0.2',
      local_addr: '192.168.0.40',
      virtual_addr: '10.2.0.4/24'
    )
  end

  def update_server_interface(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:cloudconductor_server_interface, :update, resource_name)
  end

  it 'update interface info' do
    expect(chef_run).to update_server_interface('tap1')
  end

  it 'edge node' do
    chef_run.node.set['vnet_part']['node_ref'] = 'edge1'
    chef_run.converge(described_recipe)

    expect(chef_run).to_not create_gretap('tap1')
  end
end
