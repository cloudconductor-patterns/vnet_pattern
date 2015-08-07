#
# Cookbook Name:: openvnet
# Spec:: dataset_spec
#
# Copyright 2015, TIS.inc
#
# All rights reserved - Do Not Redistribute
#

require_relative '../spec_helper'

describe 'openvnet::dataset' do
  let(:chef_run) { ChefSpec::SoloRunner.new(step_into: %w(openvnet_datapath openvnet_network openvnet_interface)) }

  before do
    chef_run.node.set['openvnet']['dataset'] = {
      datapaths: [
        {
          uuid: 'dp-1',
          node_id: 'vna1',
          display_name: 'node1',
          dpid: '0x0000aaaaaaaaaaaa'
        },
        {
          uuid: 'dp-2',
          node_id: 'vna2',
          dpid: '0x0000bbbbbbbbbbbb'
        }
      ],
      networks: [],
      interfaces: []
    }

    chef_run.converge(described_recipe)
  end

  describe 'datapaths' do
    it do
      expect(chef_run).to create_openvnet_datapath('dp-1').with(
        node_id: 'vna1',
        display_name: 'node1',
        datapath_id: '0x0000aaaaaaaaaaaa'
      )

      cmdstr = 'vnctl datapaths add --uuid dp-1 --display-name node1 --dpid 0x0000aaaaaaaaaaaa --node-id vna1'
      expect(chef_run).to run_execute(cmdstr)
    end

    it do
      expect(chef_run).to create_openvnet_datapath('dp-2').with(
        node_id: 'vna2',
        display_name: nil,
        datapath_id: '0x0000bbbbbbbbbbbb'
      )

      cmdstr = 'vnctl datapaths add --uuid dp-2 --display-name dp-2 --dpid 0x0000bbbbbbbbbbbb --node-id vna2'

      expect(chef_run).to run_execute(cmdstr)
    end
  end

  describe 'networks' do
    before do
      chef_run.node.set['openvnet']['dataset'] = {
        datapaths: [],
        networks: [
          {
            uuid: 'nw-public1',
            display_name: 'public1',
            ipv4_network: '192.168.0.0',
            ipv4_prefix: 24,
            domain_name: 'public',
            network_mode: 'physical'
          },
          {
            uuid: 'nw-public2',
            ipv4_network: '192.168.20.0'
          }
        ],
        interfaces: []
      }

      chef_run.converge(described_recipe)
    end

    it do
      expect(chef_run).to create_openvnet_network('nw-public1').with(
        display_name: 'public1',
        ipv4_network: '192.168.0.0',
        ipv4_prefix: 24,
        domain_name: 'public',
        mode: 'physical'
      )

      cmdstr = 'vnctl networks add'
      cmdstr << ' --uuid nw-public1'
      cmdstr << ' --display-name public1'
      cmdstr << ' --ipv4-network 192.168.0.0'
      cmdstr << ' --ipv4-prefix 24'
      cmdstr << ' --domain-name public'
      cmdstr << ' --network-mode physical'

      expect(chef_run).to run_execute(cmdstr)
    end

    it do
      expect(chef_run).to create_openvnet_network('nw-public2').with(
        ipv4_network: '192.168.20.0'
      )

      cmdstr = 'vnctl networks add'
      cmdstr << ' --uuid nw-public2'
      cmdstr << ' --display-name nw-public2'
      cmdstr << ' --ipv4-network 192.168.20.0'

      expect(chef_run).to run_execute(cmdstr)
    end
  end

  describe 'interfaces' do
    before do
      chef_run.node.set['openvnet']['dataset'] = {
        datapaths: [],
        networks: [],
        interfaces: [
          {
            uuid: 'if-dp1eth0',
            mode: 'host',
            port_name: 'eth0',
            owner_datapath_uuid: 'dp-1',
            network_uuid: 'nw-public1',
            mac_address: '02:01:00:00:00:01',
            ipv4_address: '192.168.10.11',
            ingress_filtering_enabled: true,
            enable_routing: true,
            enable_route_translation: true
          }
        ]
      }

      chef_run.converge(described_recipe)
    end

    it do
      expect(chef_run).to create_openvnet_interface('if-dp1eth0').with(
        mode: 'host',
        port_name: 'eth0',
        datapath: 'dp-1',
        network: 'nw-public1',
        mac_addr: '02:01:00:00:00:01',
        ipv4_addr: '192.168.10.11',
        ingress_filtering: true,
        routing: true,
        route_translation: true
      )

      cmdstr = 'vnctl interfaces add'
      cmdstr << ' --uuid if-dp1eth0'
      cmdstr << ' --ingress-filtering-enabled true'
      cmdstr << ' --enable-routing true'
      cmdstr << ' --enable-route-translation true'
      cmdstr << ' --owner-datapath-uuid dp-1'
      cmdstr << ' --network-uuid nw-public1'
      cmdstr << ' --mac-address 02:01:00:00:00:01'
      cmdstr << ' --ipv4-address 192.168.10.11'
      cmdstr << ' --port-name eth0'
      cmdstr << ' --mode host'

      expect(chef_run).to run_execute(cmdstr)
    end
  end
end
