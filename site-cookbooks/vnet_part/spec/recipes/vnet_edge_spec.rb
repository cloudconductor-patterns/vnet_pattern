#
# Cookbook Name:: vnet_part
# Spec:: vnet_edge_spec
#
# Copyright 2015, TIS.inc
#
# All rights reserved - Do Not Redistribute
#

require 'active_support'
require 'active_support/core_ext'

require_relative '../spec_helper'
require_relative '../../../cloudconductor/libraries/consul_helper.rb'
require_relative '../../../cloudconductor/libraries/consul_helper_kv.rb'

describe 'vnet_part::vnet_edge' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new(step_into: %w(openvnet_vna openvswitch_port cloudconductor_server_interface))
  end

  before do
    chef_run.node.set['cloudconductor']['servers'] = {
      edge1: {
        private_ip: '192.168.0.1',
        roles: %w(vna vnmgr)
      },
      edge2: {
        private_ip: '192.168.0.2',
        roles: 'vna'
      }
    }

    chef_run.node.set['vnet_part']['node_ref'] = 'edge1'

    chef_run.node.set['vnet_part']['networks'] = {
      networks: {},
      servers: {}
    }

    allow(CloudConductor::ConsulClient::KeyValueStore).to receive(:get).and_return('')
    allow(CloudConductor::ConsulClient::KeyValueStore).to receive(:keys).and_return('')
    allow(CloudConductor::ConsulClient::KeyValueStore).to receive(:put).and_return('')

    vna_cfg = {
      id: 'vna1',
      hwaddr: '02:99:00:01:00:01',
      datapath_id: '0x00029900010001'
    }

    allow(CloudConductor::ConsulClient::KeyValueStore).to receive(:get)
      .with('cloudconductor/networks/edge1/vna')
      .and_return(JSON.generate(vna_cfg))

    chef_run.converge(described_recipe)
  end

  it 'create vna1 resource' do
    chef_run.node.set['vnet_part']['node_ref'] = 'edge1'

    vna_cfg = {
      id: 'vna1',
      hwaddr: '02:99:99:01:00:01',
      datapath_id: '0x00029999010001'
    }

    expect(CloudConductor::ConsulClient::KeyValueStore).to receive(:get)
      .with('cloudconductor/networks/edge1/vna')
      .and_return(JSON.generate(vna_cfg))
      .once

    chef_run.converge(described_recipe)

    expect(chef_run).to create_openvnet_vna('vna1').with(
      hwaddr: '02:99:99:01:00:01',
      datapath_id: '0x00029999010001',
      registry: {
        'host' => '127.0.0.1',
        'port' => 6379
      }
    )

    expect(chef_run).to create_template('/etc/openvnet/vna.conf').with(
      source: 'vna.conf.erb',
      cookbook: 'openvnet',
      owner: 'root',
      group: 'root',
      mode: 0644,
      variables: {
        id: 'vna1',
        host: '127.0.0.1',
        public: nil,
        port: 9103
      }
    )
  end

  it 'create vna2 resource' do
    chef_run.node.set['vnet_part']['node_ref'] = 'edge2'

    vna_cfg = {
      id: 'vna2',
      hwaddr: '02:99:99:01:00:02',
      datapath_id: '0x00029999010002'
    }

    expect(CloudConductor::ConsulClient::KeyValueStore).to receive(:get)
      .with('cloudconductor/networks/edge2/vna')
      .and_return(JSON.generate(vna_cfg))
      .once

    chef_run.converge(described_recipe)

    expect(chef_run).to create_openvnet_vna('vna2').with(
      hwaddr: '02:99:99:01:00:02',
      datapath_id: '0x00029999010002',
      registry: {
        'host' => '192.168.0.1',
        'port' => 6379
      }
    )
  end

  describe 'create gretap' do
    before do
      chef_run.node.set['cloudconductor']['servers'] = {
        edge1: {
          private_ip: '192.168.0.1',
          roles: %w(vna vnmgr)
        },
        edge2: {
          private_ip: '192.168.0.2',
          roles: 'vna'
        },
        node1: {
          private_ip: '192.168.0.11',
          roles: 'web'
        },
        node2: {
          private_ip: '192.168.0.12',
          roles: 'ap'
        }
      }

      chef_run.node.set['vnet_part']['node_ref'] = 'edge1'

      chef_run.converge(described_recipe)
    end

    def create_gretap(resource_name)
      ChefSpec::Matchers::ResourceMatcher.new(:vnet_part_gretap, :create, resource_name)
    end

    def create_server_interface(resource_name)
      ChefSpec::Matchers::ResourceMatcher.new(:cloudconductor_server_interface, :create, resource_name)
    end

    it 'create gretap and add port to bridge' do
      ifcfg = {
        remote_address: '192.168.0.11',
        local_address: '192.168.0.1',
        virtual_address: '10.1.0.1'
      }.with_indifferent_access

      expect(CloudConductor::ConsulClient::KeyValueStore).to receive(:get)
        .with('cloudconductor/networks/node1/tap1')
        .and_return(JSON.generate(ifcfg))
        .at_least(:once)

      expect(CloudConductor::ConsulClient::KeyValueStore).to receive(:keys)
        .with('cloudconductor/networks/node1/')
        .and_return('["cloudconductor/networks/node1/tap1"]')
        .once

      ifcfg = {
        remote_address: '192.168.0.11',
        local_address: '192.168.0.1',
        virtual_address: '10.1.0.1',
        type: 'gretap',
        port_name: 'tap_0a010001',
        update: true
      }.with_indifferent_access
      expect(CloudConductor::ConsulClient::KeyValueStore).to receive(:put)
        .with('cloudconductor/networks/node1/tap1', ifcfg)
        .once

      chef_run.converge(described_recipe)

      expect(chef_run).to create_gretap('tap_0a010001').with(
        remote_addr: '192.168.0.11',
        local_addr: '192.168.0.1'
      )

      expect(chef_run).to create_openvswitch_port('tap_0a010001').with(
        bridge: 'br0'
      )

      expect(chef_run).to run_execute('ovs-vsctl add-port br0 tap_0a010001')

      expect(chef_run).to create_server_interface('node1_tap1').with(
        hostname: 'node1',
        if_name: 'tap1',
        port_name: 'tap_0a010001'
      )
    end
  end
end
