#
# Cookbook Name:: cloudconductor
# Spec:: library/default_spec
#
# Copyright 2015, TIS Inc.
#
# All rights reserved - Do Not Redistribute
#

require_relative '../spec_helper'
require_relative '../../libraries/default'
require_relative '../../libraries/consul_helper'
require_relative '../../libraries/consul_helper_kv'

describe 'CloudConductor::CommonHelper' do
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

    node.set['cloudconductor']['servers'] = {
      sv01: {
        private_ip: '192.168.0.1',
        roles: 'db'
      },
      sv02: {
        private_ip: '192.168.0.2',
        roles: 'web,ap'
      },
      sv03: {
        private_ip: '192.168.0.3',
        roles: 'ap'
      }
    }

    events = Chef::EventDispatch::Dispatcher.new
    run_context = Chef::RunContext.new(node, cookbook_collection, events)

    Chef::Recipe.new(cookbook_name, 'test', run_context).extend(CloudConductor::CommonHelper)
  end

  describe 'server_info' do
    it 'empty' do
      recipe.run_context.node.set['cloudconductor']['servers'] = nil
      expect(recipe.server_info('db')).to eql([])
    end

    it 'not exist' do
      expect(recipe.server_info('hoge')).to eql([])
    end

    it do
      expect(recipe.server_info('db')).to eql([
        { 'private_ip' => '192.168.0.1', 'roles' => 'db', 'hostname' => 'sv01' }
      ])
    end

    it do
      expect(recipe.server_info('web')).to eql([
        { 'private_ip' => '192.168.0.2', 'roles' => 'web,ap', 'hostname' => 'sv02' }
      ])
    end

    it do
      expect(recipe.server_info('ap')).to eql([
        { 'private_ip' => '192.168.0.2', 'roles' => 'web,ap', 'hostname' => 'sv02' },
        { 'private_ip' => '192.168.0.3', 'roles' => 'ap', 'hostname' => 'sv03' }
      ])
    end
  end

  describe 'all_servers' do
    it 'empty' do
      recipe.run_context.node.set['cloudconductor'] = nil
      expect(recipe.all_servers).to eql({})

      recipe.run_context.node.set['cloudconductor'] = {}
      expect(recipe.all_servers).to eql({})

      recipe.run_context.node.set['cloudconductor']['servers'] = nil
      expect(recipe.all_servers).to eql({})

      recipe.run_context.node.set['cloudconductor']['servers'] = {}
      expect(recipe.all_servers).to eql({})
    end

    it do
      result = {
        'sv01' => { 'private_ip' => '192.168.0.1', 'roles' => 'db' },
        'sv02' => { 'private_ip' => '192.168.0.2', 'roles' => 'web,ap' },
        'sv03' => { 'private_ip' => '192.168.0.3', 'roles' => 'ap' }
      }
      expect(recipe.all_servers).to eql(result)
    end
  end

  describe 'servers' do
    it 'empty' do
      recipe.run_context.node.set['cloudconductor']['servers'] = nil
      expect(recipe.servers('db')).to eql({})
    end

    it 'not exist' do
      expect(recipe.servers('hoge')).to eql({})
    end

    it do
      result = {
        'sv01' => { 'private_ip' => '192.168.0.1', 'roles' => 'db' }
      }
      expect(recipe.servers('db')).to eql(result)
    end

    it do
      result = {
        'sv02' => { 'private_ip' => '192.168.0.2', 'roles' => 'web,ap' }
      }
      expect(recipe.servers('web')).to eql(result)
    end

    it do
      result = {
        'sv02' => { 'private_ip' => '192.168.0.2', 'roles' => 'web,ap' },
        'sv03' => { 'private_ip' => '192.168.0.3', 'roles' => 'ap' }
      }
      expect(recipe.servers('ap')).to eql(result)
    end
  end

  describe 'host_info' do
    it 'not exist' do
      recipe.run_context.node.set['hostname'] = 'sv99'
      expect(recipe.host_info).to eql({})
    end

    it do
      recipe.run_context.node.set['hostname'] = 'sv02'
      result = { 'private_ip' => '192.168.0.2', 'roles' => 'web,ap', 'hostname' => 'sv02' }
      expect(recipe.host_info).to eql(result)
    end
  end

  describe 'host_at_name' do
    it 'not exist' do
      expect(recipe.host_at_name('sv99')).to eql({})
    end

    it do
      result = {
        'sv01' => { 'private_ip' => '192.168.0.1', 'roles' => 'db' }
      }
      expect(recipe.host_at_name('sv01')).to eql(result)
    end
  end

  describe 'patterns' do
    before do
      recipe.run_context.node.set['cloudconductor']['patterns'] = {
        tomcat_pattern: {
          type: 'platform'
        },
        amanda_pattern: {
          type: 'optional'
        },
        vnet_pattern: {
          type: 'optional'
        }
      }

      recipe.run_context.node.set['cloudconductor']['config']['patterns_dir'] = '/etc/patterns'
    end

    describe 'platform_pattern' do
      it 'empty' do
        recipe.run_context.node.set['cloudconductor']['patterns'] = nil
        expect(recipe.platform_pattern).to eql({})
      end

      it do
        result = { 'type' => 'platform', 'name' => 'tomcat_pattern' }
        expect(recipe.platform_pattern).to eq(result)
      end
    end

    describe 'optional_patterns' do
      it 'empty' do
        recipe.run_context.node.set['cloudconductor']['patterns'] = nil
        expect(recipe.optional_patterns).to eq([])
      end

      it do
        expect(recipe.optional_patterns).to eq([
          { 'type' => 'optional', 'name' => 'amanda_pattern' },
          { 'type' => 'optional', 'name' => 'vnet_pattern' }
        ])
      end
    end

    describe 'all_patterns' do
      it 'empty' do
        recipe.run_context.node.set['cloudconductor'] = nil
        expect(recipe.all_patterns).to eql({})

        recipe.run_context.node.set['cloudconductor'] = {}
        expect(recipe.all_patterns).to eql({})

        recipe.run_context.node.set['cloudconductor']['patterns'] = nil
        expect(recipe.all_patterns).to eql({})
      end

      it do
        result = {
          'tomcat_pattern' => { 'type' => 'platform' },
          'amanda_pattern' => { 'type' => 'optional' },
          'vnet_pattern' => { 'type' => 'optional' }
        }
        expect(recipe.all_patterns).to eql(result)
      end
    end

    describe 'patterns' do
      it 'empty' do
        recipe.run_context.node.set['cloudconductor']['patterns'] = nil
        expect(recipe.patterns('hoge')).to eql({})
      end

      it do
        expect(recipe.patterns('hoge')).to eql({})
      end

      it do
        result = {
          'tomcat_pattern' => { 'type' => 'platform' }
        }
        expect(recipe.patterns('platform')).to eql(result)
      end

      it do
        result = {
          'amanda_pattern' => { 'type' => 'optional' },
          'vnet_pattern' => { 'type' => 'optional' }
        }
        expect(recipe.patterns('optional')).to eql(result)
      end
    end

    it 'patterns_dir' do
      expect(recipe.patterns_dir).to eq('/etc/patterns')
    end
  end

  describe 'kvs_get' do
    it do
      key = 'cloudconductor/networks/base'
      data = {
        cloudconductor: {
          networks: {
            base: {
              networks: {
                vnet1: {
                  name: 'vnet1'
                }
              }
            }
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
      expect(recipe.kvs_get(key)).to eq(result)
    end
  end
end
