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

    it 'platform_pattern' do
      result = { 'type' => 'platform', 'name' => 'tomcat_pattern' }
      expect(recipe.platform_pattern).to eq(result)
    end

    it 'optional_patterns' do
      expect(recipe.optional_patterns).to eq([
        { 'type' => 'optional', 'name' => 'amanda_pattern' },
        { 'type' => 'optional', 'name' => 'vnet_pattern' }
      ])
    end

    it 'patterns_dir' do
      expect(recipe.patterns_dir).to eq('/etc/patterns')
    end
  end
end
