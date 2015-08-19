#
# Cookbook Name:: vnet_part
# Spec:: vnet_dataset_spec
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

describe 'vnet_part::vnet_dataset' do
  let(:chef_run) { ChefSpec::SoloRunner.new }

  before do
    chef_run.node.set['cloudconductor']['servers'] = {
      edge1: {
        private_ip: '192.168.0.1',
        roles: %w(vna vnmgr)
      },
      node1: {
        private_ip: '192.168.0.11',
        roles: 'web'
      },
      node2: {
        private_ip: '192.168.0.12',
        roles: 'ap'
      },
      node3: {
        private_ip: '192.168.0.13',
        roles: 'db'
      }
    }
    chef_run.node.set['vnet_part']['node_ref'] = 'edge1'
    chef_run.node.set['vnet_part']['config'] = {
      network: {
        virtual: {
          addr: '10.1.0.0',
          mask: 24
        }
      }
    }

    chef_run.node.set['vnet_part']['networks'] = {
      networks: {},
      servers: {},
      security_groups: {}
    }

    allow(CloudConductor::ConsulClient::KeyValueStore).to receive(:get).and_return('')
    allow(CloudConductor::ConsulClient::KeyValueStore).to receive(:keys).and_return('')
    allow(CloudConductor::ConsulClient::KeyValueStore).to receive(:put).and_return('')

    vna_cfg = {
      id: 'vna00',
      hwaddr: '02:00:00:00:00:01',
      datapath_id: '0x00020000000001'
    }

    allow(CloudConductor::ConsulClient::KeyValueStore).to receive(:get)
      .with('cloudconductor/networks/edge1/vna')
      .and_return(JSON.generate(vna_cfg))

    chef_run.converge(described_recipe)
  end

  it 'include openvnet::dataset recipe' do
    expect(chef_run).to include_recipe('openvnet::dataset')
  end

  describe 'datapaths' do
    before do
      vna_cfg = {
        id: 'vna1',
        hwaddr: '02:99:99:01:00:01',
        datapath_id: '0x00029999010001'
      }

      expect(CloudConductor::ConsulClient::KeyValueStore).to receive(:get)
        .with('cloudconductor/networks/edge1/vna')
        .and_return(JSON.generate(vna_cfg))
        .at_least(:once)

      chef_run.converge(described_recipe)
    end

    it 'create dataset of datapaths' do
      datapaths = []
      dpcfg = {
        uuid: 'dp-01',
        node_id: 'vna1',
        display_name: 'edge1',
        dpid: '0x00029999010001'
      }.with_indifferent_access

      datapaths << dpcfg

      expect(chef_run.node['openvnet']['dataset']['datapaths']).to eql(datapaths)
    end

    it 'create openvnet datapath resource' do
      expect(chef_run).to create_openvnet_datapath('dp-01').with(
        datapath_id: '0x00029999010001',
        display_name: 'edge1',
        node_id: 'vna1'
      )
    end
  end

  describe 'networks' do
    before do
      chef_run.node.set['vnet_part']['networks']['networks'] = {
        vnet1: {
        }
      }

      chef_run.converge(described_recipe)
    end

    it 'create dataset of networks' do
      networks = []
      nwcfg = {
        uuid: 'nw-vnet1',
        display_name: 'vnet1',
        ipv4_network: '10.1.0.0',
        ipv4_prefix: 24,
        domain_name: 'vnet1',
        network_mode: 'virtual'
      }.with_indifferent_access

      networks << nwcfg

      expect(chef_run.node['openvnet']['dataset']['networks']).to eql(networks)
    end

    it 'create openvnet_network resource' do
      expect(chef_run).to create_openvnet_network('nw-vnet1').with(
        display_name: 'vnet1',
        ipv4_network: '10.1.0.0',
        ipv4_prefix: 24,
        domain_name: 'vnet1',
        mode: 'virtual'
      )
    end
  end

  describe 'interfaces' do
    before do
      # -- node1 / tap1 --
      expect(CloudConductor::ConsulClient::KeyValueStore).to receive(:keys)
        .with('cloudconductor/networks/node1/')
        .and_return('["cloudconductor/networks/node1/tap1"]')
        .at_least(:once)

      if_cfg_01 = {
        type: 'gretap',
        network: 'vnet1',
        security_groups: [
          'sg-web',
          'sg-shared'
        ],
        virtual_address: '10.1.0.11',
        uuid: nil,
        port_name: 'n1tap1',
        hwaddr: '02:01:99:01:01:01'
      }

      expect(CloudConductor::ConsulClient::KeyValueStore).to receive(:get)
        .with('cloudconductor/networks/node1/tap1')
        .and_return(JSON.generate(if_cfg_01))
        .at_least(:once)

      # -- node2 / tap1 --
      expect(CloudConductor::ConsulClient::KeyValueStore).to receive(:keys)
        .with('cloudconductor/networks/node2/')
        .and_return('["cloudconductor/networks/node2/tap1"]')
        .at_least(:once)

      if_cfg_01 = {
        type: 'gretap',
        network: 'vnet1',
        security_groups: nil,
        virtual_address: '10.1.0.12',
        uuid: nil,
        port_name: 'n2tap1',
        hwaddr: '02:02:99:01:01:02'
      }

      expect(CloudConductor::ConsulClient::KeyValueStore).to receive(:get)
        .with('cloudconductor/networks/node2/tap1')
        .and_return(JSON.generate(if_cfg_01))
        .at_least(:once)

      # -- node3 / tap1 --
      expect(CloudConductor::ConsulClient::KeyValueStore).to receive(:keys)
        .with('cloudconductor/networks/node3/')
        .and_return('["cloudconductor/networks/node3/tap1"]')
        .at_least(:once)

      if_cfg_01 = {
        type: 'gretap',
        network: 'vnet1',
        security_groups: [
          'sg-db',
          'sg-shared'
        ],
        virtual_address: '10.1.0.13',
        uuid: 'if-db1tap1',
        port_name: 'n3tap1',
        hwaddr: '02:01:99:03:01:03'
      }

      expect(CloudConductor::ConsulClient::KeyValueStore).to receive(:get)
        .with('cloudconductor/networks/node3/tap1')
        .and_return(JSON.generate(if_cfg_01))
        .at_least(:once)

      chef_run.converge(described_recipe)
    end

    it 'create dataset of interfaces' do
      interfaces = []
      ifcfg = {
        uuid: 'if-n1tap1',
        port_name: 'n1tap1',
        owner_datapath_uuid: 'dp-01',
        network_uuid: 'nw-vnet1',
        mac_address: '02:01:99:01:01:01',
        ingress_filtering_enabled: true,
        ipv4_address: '10.1.0.11'
      }.with_indifferent_access

      interfaces << ifcfg

      ifcfg = {
        uuid: 'if-n2tap1',
        port_name: 'n2tap1',
        owner_datapath_uuid: 'dp-01',
        network_uuid: 'nw-vnet1',
        mac_address: '02:02:99:01:01:02',
        ingress_filtering_enabled: false,
        ipv4_address: '10.1.0.12'
      }.with_indifferent_access

      interfaces << ifcfg

      ifcfg = {
        uuid: 'if-db1tap1',
        port_name: 'n3tap1',
        owner_datapath_uuid: 'dp-01',
        network_uuid: 'nw-vnet1',
        mac_address: '02:01:99:03:01:03',
        ingress_filtering_enabled: true,
        ipv4_address: '10.1.0.13'
      }.with_indifferent_access

      interfaces << ifcfg

      expect(chef_run.node['openvnet']['dataset']['interfaces']).to eql(interfaces)
    end

    it 'create openvnet_interface resource' do
      expect(chef_run).to create_openvnet_interface('if-n1tap1').with(
        datapath: 'dp-01',
        network: 'nw-vnet1',
        ipv4_addr: '10.1.0.11',
        mac_addr: '02:01:99:01:01:01',
        port_name: 'n1tap1'
      )

      expect(chef_run).to create_openvnet_interface('if-n2tap1').with(
        datapath: 'dp-01',
        network: 'nw-vnet1',
        ipv4_addr: '10.1.0.12',
        mac_addr: '02:02:99:01:01:02',
        port_name: 'n2tap1'
      )

      expect(chef_run).to create_openvnet_interface('if-db1tap1').with(
        datapath: 'dp-01',
        network: 'nw-vnet1',
        ipv4_addr: '10.1.0.13',
        mac_addr: '02:01:99:03:01:03',
        port_name: 'n3tap1'
      )
    end

    describe 'interface_security_groups' do
      it 'create dataset for interface_security_groups' do
        if_sg = []

        cfg = {
          interface_uuid: 'if-n1tap1',
          security_group_uuid: 'sg-web'
        }.with_indifferent_access
        if_sg << cfg

        cfg = {
          interface_uuid: 'if-n1tap1',
          security_group_uuid: 'sg-shared'
        }.with_indifferent_access
        if_sg << cfg

        cfg = {
          interface_uuid: 'if-db1tap1',
          security_group_uuid: 'sg-db'
        }.with_indifferent_access
        if_sg << cfg

        cfg = {
          interface_uuid: 'if-db1tap1',
          security_group_uuid: 'sg-shared'
        }.with_indifferent_access
        if_sg << cfg

        expect(chef_run.node['openvnet']['dataset']['interface_security_groups']).to eql(if_sg)
      end
    end

    describe 'security_groups' do
      before do
        chef_run.node.set['vnet_part']['networks']['security_groups'] = {
          'sg-shared' => {
            rules: [
              'tcp:22:0.0.0.0/0',
              'icmp:-1:0.0.0.0/0'
            ]
          }
        }

        chef_run.converge(described_recipe)
      end

      it 'create openvnet_security_group resource' do
        expect(chef_run).to create_openvnet_security_group('sg-shared').with(
          display_name: 'sg-shared',
          rules: [
            'tcp:22:0.0.0.0/0',
            'icmp:-1:0.0.0.0/0'
          ],
          interfaces: [
            'if-n1tap1',
            'if-db1tap1'
          ]
        )
      end
    end
  end

  describe 'security_groups' do
    before do
    end

    it 'create dataset for security_groups' do
      chef_run.node.set['vnet_part']['networks']['security_groups'] = {
        'sg-shared' => {
          rules: [
            'tcp:22:0.0.0.0/0',
            'icmp:-1:0.0.0.0/0'
          ]
        }
      }

      chef_run.converge(described_recipe)

      security_groups = []

      sg_cfg = {
        uuid: 'sg-shared',
        display_name: 'sg-shared',
        rules: [
          'tcp:22:0.0.0.0/0',
          'icmp:-1:0.0.0.0/0'
        ]
      }.with_indifferent_access

      security_groups << sg_cfg

      expect(chef_run.node['openvnet']['dataset']['security_groups']).to eql(security_groups)
    end
  end
end
