#
# Cookbook Name:: vnet_part
# Spec:: recipe/vnet_configure_spec
#
# Copyright 2015, TIS Inc
#
# All rights reserved - Do Not Redistribute
#

require 'active_support'
require 'active_support/core_ext'

require_relative '../spec_helper'
require_relative '../../../cloudconductor/libraries/consul_helper.rb'
require_relative '../../../cloudconductor/libraries/consul_helper_kv.rb'

describe 'vnet_part::vnet_configure' do
  def patterns_dir
    File.expand_path('../../../../../', File.dirname(__FILE__))
  end

  let(:chef_run) do
    ChefSpec::SoloRunner.new(step_into: %w(cloudconductor_vnet_edge cloudconductor_server_interface))
  end

  before do
    chef_run.node.set['cloudconductor']['patterns'] = {
      vnet_pattern: {
        type: 'optional'
      },
      tomcat_pattern: {
        type: 'platform'
      }
    }

    chef_run.node.set['cloudconductor']['servers'] = {
      edge1: {
        private_ip: '192.168.0.1',
        roles: %w(vna vnmgr),
        pattern: 'vnet_pattern'
      },
      node1: {
        private_ip: '192.168.0.11',
        roles: 'web',
        pattern: 'pattern_name'
      }
    }

    chef_run.node.set['cloudconductor']['networks'] = nil

    chef_run.node.set['cloudconductor']['config']['patterns_dir'] = patterns_dir

    chef_run.node.set['vnet_part']['node_ref'] = 'edge1'

    allow(CloudConductor::ConsulClient::KeyValueStore).to receive(:get).and_return('{}')
    allow(CloudConductor::ConsulClient::KeyValueStore).to receive(:keys).and_return('[]')
    allow(CloudConductor::ConsulClient::KeyValueStore).to receive(:put)

    nwcfg_default = {
      networks: {},
      servers: {}
    }
    allow(YAML).to receive(:load_file)
      .with("#{patterns_dir}/vnet_pattern/network.yml")
      .and_return(nwcfg_default)

    nwcfg_tomcat = {
      networks: {},
      servers: {}
    }
    allow(YAML).to receive(:load_file)
      .with("#{patterns_dir}/tomcat_pattern/network.yml")
      .and_return(nwcfg_tomcat)

    #    chef_run.converge(described_recipe)
  end

  def create_vnet_edge(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:cloudconductor_vnet_edge, :create, resource_name)
  end

  it 'load network.yml files' do
    nwcfg_default = {
      networks: {},
      servers: {}
    }
    expect(YAML).to receive(:load_file)
      .with("#{patterns_dir}/vnet_pattern/network.yml")
      .and_return(nwcfg_default)
      .once

    nwcfg_tomcat = {
      networks: {},
      servers: {}
    }
    expect(YAML).to receive(:load_file)
      .with("#{patterns_dir}/tomcat_pattern/network.yml")
      .and_return(nwcfg_tomcat)
      .once

    chef_run.converge(described_recipe)
  end

  describe 'create vna definitions' do
    it 'new' do
      expect(CloudConductor::ConsulClient::KeyValueStore).to receive(:get)
        .with('cloudconductor/networks/edge1/vna')
        .and_return(nil).once

      vnacfg = {
        id: 'vna1',
        hwaddr: '02:00:01:01:00:01',
        datapath_id: '0x00020001010001'
      }.with_indifferent_access

      expect(CloudConductor::ConsulClient::KeyValueStore).to receive(:put)
        .with('cloudconductor/networks/edge1/vna', vnacfg).once

      chef_run.converge(described_recipe)

      expect(chef_run).to create_vnet_edge('edge1').with(
        vna_id: 'vna1',
        hwaddr: '02:00:01:01:00:01',
        datapath_id: '0x00020001010001'
      )
    end

    it 'update' do
      expect(CloudConductor::ConsulClient::KeyValueStore).to receive(:get)
        .with('cloudconductor/networks/edge1/vna')
        .and_return('{"bridge":"br0"}').once

      vnacfg = {
        bridge: 'br0',
        id: 'vna1',
        hwaddr: '02:00:01:01:00:01',
        datapath_id: '0x00020001010001'
      }.with_indifferent_access

      expect(CloudConductor::ConsulClient::KeyValueStore).to receive(:put)
        .with('cloudconductor/networks/edge1/vna', vnacfg).once

      chef_run.converge(described_recipe)

      expect(chef_run).to create_vnet_edge('edge1').with(
        vna_id: 'vna1',
        hwaddr: '02:00:01:01:00:01',
        datapath_id: '0x00020001010001'
      )
    end

    it 'none update' do
      vnacfg = {
        bridge: 'br0',
        id: 'vna1',
        hwaddr: '02:00:01:01:00:01',
        datapath_id: '0x00020001010001'
      }.with_indifferent_access

      expect(CloudConductor::ConsulClient::KeyValueStore).to receive(:get)
        .with('cloudconductor/networks/edge1/vna')
        .and_return(JSON.generate(vnacfg)).once

      expect(CloudConductor::ConsulClient::KeyValueStore).to_not receive(:put)
        .with('cloudconductor/networks/edge1/vna', vnacfg)

      chef_run.converge(described_recipe)

      expect(chef_run).to create_vnet_edge('edge1').with(
        vna_id: 'vna1',
        hwaddr: '02:00:01:01:00:01',
        datapath_id: '0x00020001010001'
      )
    end
  end

  describe 'some edge' do
    before do
      chef_run.node.set['cloudconductor']['servers'] = {
        edge1: {
          private_ip: '192.168.0.1',
          roles: %w(vna vnmgr),
          pattern: 'vnet_pattern'
        },
        edge2: {
          private_ip: '192.168.0.2',
          roles: 'vna',
          pattern: 'vnet_pattern'
        },
        edge3: {
          private_ip: '192.168.0.3',
          roles: 'vnmgr'
        },
        edge4: {
          private_ip: '192.168.0.4',
          roles: 'vna'
        }
      }

      chef_run.converge(described_recipe)
    end

    it 'create vna definitions' do
      expect(chef_run).to create_vnet_edge('edge1').with(
        vna_id: 'vna1',
        hwaddr: '02:00:01:01:00:01',
        datapath_id: '0x00020001010001'
      )

      expect(chef_run).to create_vnet_edge('edge2').with(
        vna_id: 'vna2',
        hwaddr: '02:00:01:01:00:02',
        datapath_id: '0x00020001010002'
      )

      expect(chef_run).to_not create_vnet_edge('edge3')

      expect(chef_run).to create_vnet_edge('edge4').with(
        vna_id: 'vna3',
        hwaddr: '02:00:01:01:00:03',
        datapath_id: '0x00020001010003'
      )
    end
  end

  def create_server_interface(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:cloudconductor_server_interface, :create, resource_name)
  end

  describe 'configure_interface' do
    before do
      allow(CloudConductor::ConsulClient::KeyValueStore)
        .to receive(:get)
        .with('cloudconductor/networks/node1/tap1')
        .and_return('{}')

      allow(CloudConductor::ConsulClient::KeyValueStore)
        .to receive(:keys)
        .with('cloudconductor/networks/node1/')
        .and_return('[]')

      chef_run.converge(described_recipe)
    end

    it 'create from default network.yml' do
      nwcfg_default = {
        networks: {
          vnet1: {}
        },
        servers: {
          default: {
            role: 'all',
            interfaces: {
              tap1: {
                type: 'gretap',
                network: 'vnet1'
              }
            }
          }
        }
      }.with_indifferent_access
      expect(YAML).to receive(:load_file)
        .with("#{patterns_dir}/vnet_pattern/network.yml")
        .and_return(nwcfg_default)
        .once

      expect(CloudConductor::ConsulClient::KeyValueStore)
        .to receive(:get)
        .with('cloudconductor/networks/node1/tap1')
        .at_least(:once)

      ifcfg = {
        'type' => 'gretap',
        'virtual_address' => '10.1.0.1',
        'update' => true
      }

      expect(CloudConductor::ConsulClient::KeyValueStore)
        .to receive(:put)
        .with('cloudconductor/networks/node1/tap1', ifcfg)
        .at_least(:once)

      chef_run.converge(described_recipe)

      expect(chef_run).to create_server_interface('node1_tap1').with(
        hostname: 'node1',
        if_name: 'tap1',
        virtual_address: '10.1.0.1'
      )
    end

    it 'create from network.yml in pattern' do
      nwcfg_tomcat = {
        networks: {
          vnet1: {},
          vnet2: {
            ipv4_address: '10.20.0.0'
          }
        },
        servers: {
          web_sv: {
            role: 'web',
            interfaces: {
              tap2: {
                type: 'gretap',
                network: 'vnet2'
              }
            }
          }
        }
      }

      expect(YAML).to receive(:load_file)
        .with("#{patterns_dir}/tomcat_pattern/network.yml")
        .and_return(nwcfg_tomcat)
        .once

      chef_run.converge(described_recipe)

      expect(chef_run).to_not create_server_interface('node1_tap1')

      expect(chef_run).to create_server_interface('node1_tap2').with(
        hostname: 'node1',
        if_name: 'tap2',
        virtual_address: '10.20.0.1'
      )
    end
  end
end
