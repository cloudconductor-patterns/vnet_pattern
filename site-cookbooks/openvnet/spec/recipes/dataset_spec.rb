#
# Cookbook Name:: openvnet
# Spec:: dataset_spec
#
# Copyright 2015, TIS.inc
#
# All rights reserved - Do Not Redistribute
#

require_relative '../spec_helper'
require 'vnet_api_client'

describe 'openvnet::dataset' do
  let(:chef_run) { ChefSpec::SoloRunner.new(step_into: %w(openvnet_datapath openvnet_network openvnet_interface)) }

  describe 'datapaths' do
    before do
      chef_run.node.set['openvnet']['config'] = {
        webapi: {
          host: 'localhost',
          port: '9101'
        }
      }
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

      allow(VNetAPIClient::Datapath).to receive(:create).and_return(nil)
      allow(VNetAPIClient::Interface).to receive(:create).and_return(nil)
      allow(VNetAPIClient::Network).to receive(:create).and_return(nil)

      chef_run.converge(described_recipe)
    end

    it do
      expect(VNetAPIClient::ApiResource.api_uri).to eq('http://localhost:9101')
    end

    it do
      expect(chef_run).to create_openvnet_datapath('dp-1').with(
        node_id: 'vna1',
        display_name: 'node1',
        datapath_id: '0x0000aaaaaaaaaaaa'
      )
    end

    it do
      expect(chef_run).to create_openvnet_datapath('dp-2').with(
        node_id: 'vna2',
        display_name: nil,
        datapath_id: '0x0000bbbbbbbbbbbb'
      )
    end

    it do
      params = {
        uuid: 'dp-1',
        dpid: '0x0000aaaaaaaaaaaa',
        node_id: 'vna1',
        display_name: 'node1'
      }
      expect(VNetAPIClient::Datapath).to receive(:create).with(params)
      chef_run.converge(described_recipe)
    end

    it do
      params = {
        uuid: 'dp-2',
        dpid: '0x0000bbbbbbbbbbbb',
        node_id: 'vna2',
        display_name: 'dp-2'
      }
      expect(VNetAPIClient::Datapath).to receive(:create).with(params)
      chef_run.converge(described_recipe)
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

      allow(VNetAPIClient::Datapath).to receive(:create).and_return(nil)
      allow(VNetAPIClient::Interface).to receive(:create).and_return(nil)
      allow(VNetAPIClient::Network).to receive(:create).and_return(nil)

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
    end

    it do
      params = {
        uuid: 'nw-public1',
        ipv4_network: '192.168.0.0',
        display_name: 'public1',
        ipv4_prefix: 24,
        domain_name: 'public',
        network_mode: 'physical'
      }
      expect(VNetAPIClient::Network).to receive(:create).with(params)
      chef_run.converge(described_recipe)
    end

    it do
      expect(chef_run).to create_openvnet_network('nw-public2').with(
        ipv4_network: '192.168.20.0'
      )
    end

    it do
      params = {
        uuid: 'nw-public2',
        display_name: 'nw-public2',
        ipv4_network: '192.168.20.0'
      }
      expect(VNetAPIClient::Network).to receive(:create).with(params)
      chef_run.converge(described_recipe)
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

      allow(VNetAPIClient::Datapath).to receive(:create).and_return(nil)
      allow(VNetAPIClient::Interface).to receive(:create).and_return(nil)
      allow(VNetAPIClient::Network).to receive(:create).and_return(nil)

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
    end

    it do
      params = {
        uuid: 'if-dp1eth0',
        ingress_filtering_enabled: true,
        enable_routing: true,
        enable_route_translation: true,
        owner_datapath_uuid: 'dp-1',
        network_uuid: 'nw-public1',
        mac_address: '02:01:00:00:00:01',
        ipv4_address: '192.168.10.11',
        port_name: 'eth0',
        mode: 'host'
      }
      expect(VNetAPIClient::Interface).to receive(:create).with(params)
      chef_run.converge(described_recipe)
    end
  end
end
