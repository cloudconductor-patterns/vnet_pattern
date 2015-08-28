#
# Cookbook Name:: vnet_part
# Spec:: library/default_spec
#
# Copyright 2015, TIS Inc.
#
# All rights reserved - Do Not Redistribute
#

require_relative '../spec_helper'
require_relative '../../../cloudconductor/libraries/consul_helper'
require_relative '../../../cloudconductor/libraries/consul_helper_kv'
require_relative '../../../cloudconductor/libraries/default'
require_relative '../../libraries/default'

describe 'CloudConductor::VnetPartHelper' do
  def cookbook_root
    File.expand_path('../../', File.dirname(__FILE__))
  end

  def cookbook_name
    File.basename(cookbook_root)
  end

  let(:recipe) do
    cookbook_version = Chef::CookbookVersion.new(cookbook_name, cookbook_root)
    cookbook_versions = { cookbook_name => cookbook_version }
    cookbook_collection = Chef::CookbookCollection.new(cookbook_versions)

    node = Chef::Node.new

    node.set['vnet_part']['node_ref'] = nil
    node.set['vnet_part']['keys']['networks']['base'] = 'cloudconductor/networks/base'
    node.set['vnet_part']['keys']['networks']['prefix'] = 'cloudconductor/networks/'
    node.set['cloudconductor']['servers'] = {
      node01: {
        private_ip: '192.168.0.1'
      },
      node02: {
        private_ip: '192.168.0.2'
      }
    }
    node.set['ipaddress'] = '192.168.0.1'

    events = Chef::EventDispatch::Dispatcher.new

    run_context = Chef::RunContext.new(node, cookbook_collection, events)

    Chef::Recipe.new(cookbook_name, 'test', run_context).extend(CloudConductor::VnetPartHelper)
  end

  describe 'host_info' do
    it do
      ret = { 'private_ip' => '192.168.0.1', 'hostname' => 'node01' }
      expect(recipe.host_info).to eql(ret)
    end

    it do
      recipe.run_context.node.set['ipaddress'] = '192.168.0.3'
      recipe.run_context.node.set['hostname'] = 'node04'
      ret = {}
      expect(recipe.host_info).to eql(ret)
    end

    it do
      recipe.run_context.node.set['vnet_part']['node_ref'] = 'node03'

      ret = {}

      expect(recipe.host_info).to eql(ret)
    end

    it do
      recipe.run_context.node.set['vnet_part']['node_ref'] = 'node02'

      ret = { 'private_ip' => '192.168.0.2', 'hostname' => 'node02' }

      expect(recipe.host_info).to eql(ret)
    end
  end

  describe 'networks_base' do
    it do
      data = {
        networks: {
          vnet1: {
            name: 'vnet1'
          }
        }
      }
      expect(CloudConductor::ConsulClient::KeyValueStore).to receive(:get)
        .with('cloudconductor/networks/base')
        .and_return(JSON.generate(data))

      result = {
        'networks' => {
          'vnet1' => {
            'name' => 'vnet1'
          }
        }
      }
      expect(recipe.networks_base).to eq(result)
    end
  end

  describe 'network_conf' do
    it do
      recipe.run_context.node.set['vnet_part']['networks'] = nil
      allow(CloudConductor::ConsulClient::KeyValueStore).to receive(:get).and_return(nil)

      expect(recipe.network_conf).to eq({})

      expect(recipe.run_context.node['vnet_part']['networks']).to eq({})
    end

    it do
      recipe.run_context.node.set['vnet_part']['networks'] = nil

      allow(CloudConductor::ConsulClient::KeyValueStore)
        .to receive(:get)
        .with('cloudconductor/networks/base')
        .and_return('{"networks": {"vnet1":{"name":"vnet1"}}}')

      result = { 'networks' => { 'vnet1' => { 'name' => 'vnet1' } } }
      expect(recipe.network_conf).to eq(result)

      expect(recipe.run_context.node['vnet_part']['networks']).to eq(result)
    end

    it do
      recipe.run_context.node.set['vnet_part']['networks'] = {
        'networks' => { 'vnet1' => { 'name' => 'vnet1' } }
      }
      allow(CloudConductor::ConsulClient::KeyValueStore).to receive(:get).and_return(nil)

      result = { 'networks' => { 'vnet1' => { 'name' => 'vnet1' } } }
      expect(recipe.network_conf).to eq(result)

      expect(recipe.run_context.node['vnet_part']['networks']).to eq(result)
    end

    it do
      recipe.run_context.node.set['vnet_part']['networks'] = {
        'networks' => { 'vnet1' => { 'name' => 'vnet1' } }
      }
      allow(CloudConductor::ConsulClient::KeyValueStore).to receive(:get).and_return('{}')

      result = { 'networks' => { 'vnet1' => { 'name' => 'vnet1' } } }
      expect(recipe.network_conf).to eq(result)

      expect(recipe.run_context.node['vnet_part']['networks']).to eq(result)
    end

    it do
      recipe.run_context.node.set['vnet_part']['networks'] = {
        'networks' => {
          'vnet1' => { 'name' => 'vnet1', 'ipv4_address' => '10.1.0.0' },
          'vnet3' => { 'name' => 'vnet3', 'ipv4_address' => '10.3.0.0' }
        }
      }

      network_conf = {
        'networks' => {
          'vnet1' => {
            'name' => 'vnet1',
            'ipv4_address' => '192.168.10.0'
          },
          'vnet2' => {
            'name' => 'vnet2',
            'ipv4_address' => '192.168.20.0'
          }
        }
      }

      allow(CloudConductor::ConsulClient::KeyValueStore)
        .to receive(:get)
        .with('cloudconductor/networks/base')
        .and_return(JSON.generate(network_conf))

      result = {
        'networks' => {
          'vnet1' => { 'name' => 'vnet1', 'ipv4_address' => '10.1.0.0' },
          'vnet2' => { 'name' => 'vnet2', 'ipv4_address' => '192.168.20.0' },
          'vnet3' => { 'name' => 'vnet3', 'ipv4_address' => '10.3.0.0' }
        }
      }
      expect(recipe.network_conf).to eq(result)
    end
  end

  describe 'gretap_interfaces' do
    before do
      allow(CloudConductor::ConsulClient::KeyValueStore)
        .to receive(:get)
        .with('cloudconductor/networks/base')
        .and_return(nil)

      recipe.run_context.node.set['vnet_part']['networks'] = {
        'servers' => {
          'web_sv' => {
            'role' => 'web'
          }
        }
      }
    end

    it do
      allow(CloudConductor::ConsulClient::KeyValueStore)
        .to receive('keys')
        .with('cloudconductor/networks/node1/')
        .and_return(nil)

      sv_info = { 'hostname' => 'node1', 'roles' => %w(web ap) }
      expect(recipe.gretap_interfaces(sv_info))
        .to eq({})
    end

    it do
      allow(CloudConductor::ConsulClient::KeyValueStore)
        .to receive('keys')
        .with('cloudconductor/networks/node1/')
        .and_return('[]')

      sv_info = { 'hostname' => 'node1', 'roles' => %w(web ap) }
      expect(recipe.gretap_interfaces(sv_info))
        .to eq({})
    end

    it do
      allow(CloudConductor::ConsulClient::KeyValueStore)
        .to receive('keys')
        .with('cloudconductor/networks/node1/')
        .and_return('["cloudconductor/networks/node1/tap1"]')

      allow(CloudConductor::ConsulClient::KeyValueStore)
        .to receive('get')
        .with('cloudconductor/networks/node1/tap1')
        .and_return(nil)

      sv_info = { 'hostname' => 'node1', 'roles' => %w(web ap) }
      expect(recipe.gretap_interfaces(sv_info))
        .to eq({})
    end

    it do
      recipe.run_context.node.set['vnet_part']['networks'] = {
        'servers' => {
          'web_sv' => {
            'role' => 'web',
            'interfaces' => {
              'tap1' => {
                'type' => 'gretap',
                'network' => 'vnet1',
                'security_groups' => [
                  'sg-web',
                  'sg-shared'
                ]
              }
            }
          },
          'ap_sv' => {
            'role' => 'ap',
            'interfaces' => {
              'tap1' => {
                'type' => 'gretap',
                'network' => 'vnet1',
                'security_groups' => [
                  'sg-ap',
                  'sg-shared'
                ]
              }
            }
          }
        }
      }

      allow(CloudConductor::ConsulClient::KeyValueStore)
        .to receive('keys')
        .with('cloudconductor/networks/node1/')
        .and_return('["cloudconductor/networks/node1/tap1","cloudconductor/networks/node1/tap2"]')

      allow(CloudConductor::ConsulClient::KeyValueStore)
        .to receive('get')
        .with('cloudconductor/networks/node1/tap1')
        .and_return('{"virtual_address":"10.1.0.1"}')

      allow(CloudConductor::ConsulClient::KeyValueStore)
        .to receive('get')
        .with('cloudconductor/networks/node1/tap2')
        .and_return('{"virtual_address":"10.1.0.2"}')

      sv_info = { 'hostname' => 'node1', 'roles' => %w(web ap) }
      result = {
        'tap1' => {
          'virtual_address' => '10.1.0.1',
          'type' => 'gretap',
          'network' => 'vnet1',
          'security_groups' => [
            'sg-web',
            'sg-shared',
            'sg-ap'
          ],
          'update' => true
        },
        'tap2' => {
          'virtual_address' => '10.1.0.2'
        }
      }
      expect(recipe.gretap_interfaces(sv_info))
        .to eq(result)
    end
  end
end
