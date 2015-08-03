#
# Cookbook Name:: vnet_part
# Spec:: library/default_spec
#
# Copyright 2015, TIS Inc.
#
# All rights reserved - Do Not Redistribute
#

require_relative '../spec_helper'
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

  it do
    ret = { 'private_ip' => '192.168.0.1', 'hostname' => 'node01' }
    expect(recipe.host_info).to eql(ret)
  end

  it do
    recipe.run_context.node.set['vnet_part']['node_ref'] = 'node03'

    ret = { 'hostname' => 'node03' }

    expect(recipe.host_info).to eql(ret)
  end

  it do
    recipe.run_context.node.set['vnet_part']['node_ref'] = 'node02'

    ret = { 'private_ip' => '192.168.0.2', 'hostname' => 'node02' }

    expect(recipe.host_info).to eql(ret)
  end
end
