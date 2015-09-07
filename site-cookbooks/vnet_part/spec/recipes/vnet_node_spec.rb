#
# Cookbook Name:: vnet_part
# Spec:: recipies/vnet_node_spec
#
# Copyright 2015, TIS Inc.
#
# All rights reserved - Do Not Redistribute
#

require 'active_support'
require 'active_support/core_ext'

require_relative '../spec_helper'
require_relative '../../../cloudconductor/libraries/consul_helper.rb'
require_relative '../../../cloudconductor/libraries/consul_helper_kv.rb'

describe 'vnet_part::vnet_node' do
  let(:chef_run) { ChefSpec::SoloRunner.new(step_into: %w(vnet_part_gretap cloudconductor_server_interface)) }

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
        public_ip: '',
        roles: %w(vna vnmgr)
      },
      node1: {
        private_ip: '192.168.0.10',
        roles: ['web']
      }
    }

    # chef_run.node.set['ipaddress'] = '192.168.0.10'
    chef_run.node.set['vnet_part']['node_ref'] = 'node1'

    allow(CloudConductor::ConsulClient::KeyValueStore)
      .to receive(:get)
      .and_return('')

    allow(CloudConductor::ConsulClient::KeyValueStore)
      .to receive(:keys)
      .and_return('')

    allow(CloudConductor::ConsulClient::KeyValueStore)
      .to receive(:put)
      .and_return('')

    netwrok_conf = {
      networks: {
        vnet1: {
          ipv4_address: '10.1.0.0',
          ipv4_prefix: 24
        }
      },
      servers: {
        web_sv: {
          role: 'web',
          interfaces: {
            tap1: {
              type: 'gretap',
              network: 'vnet1'
            }
          }
        }
      }
    }

    chef_run.node.set['vnet_part']['networks'] = netwrok_conf

    chef_run.converge(described_recipe)
  end

  def create_gretap(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:vnet_part_gretap, :create, resource_name)
  end

  def create_server_interface(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:cloudconductor_server_interface, :create, resource_name)
  end

  it 'create gretap and add ipaddr' do
    chef_run.node.set['vnet_part']['node_ref'] = 'node1'

    expect(CloudConductor::ConsulClient::KeyValueStore)
      .to receive(:keys)
      .with('cloudconductor/networks/node1/')
      .and_return('["cloudconductor/networks/node1/tap1"]')

    ifcfg = {
      cloudconductor: {
        networks: {
          node1: {
            tap1: {
              virtual_address: '10.1.0.1'
            }
          }
        }
      }
    }.with_indifferent_access

    expect(CloudConductor::ConsulClient::KeyValueStore)
      .to receive(:get)
      .with('cloudconductor/networks/node1/tap1')
      .and_return(JSON.generate(ifcfg))

    allow_any_instance_of(Mixlib::ShellOut).to receive(:error!).and_return(0)
    allow_any_instance_of(Mixlib::ShellOut).to receive(:stdout).and_return('02:00:0a:01:00:01')

    ret_ifcfg = {
      cloudconductor: {
        networks: {
          node1: {
            tap1: {
              type: 'gretap',
              remote_address: '192.168.0.1',
              local_address: '192.168.0.10',
              virtual_address: '10.1.0.1',
              virtual_prefix: 24,
              hwaddr: '02:00:0a:01:00:01'
            }
          }
        }
      }
    }.with_indifferent_access

    expect(CloudConductor::ConsulClient::KeyValueStore)
      .to receive(:put)
      .with('cloudconductor/networks/node1/tap1', ret_ifcfg)
      .once

    chef_run.converge(described_recipe)

    expect(chef_run).to create_gretap('tap1').with(
      remote_addr: '192.168.0.1',
      local_addr: '192.168.0.10',
      virtual_addr: '10.1.0.1',
      virtual_prefix: 24
    )
    expect(chef_run).to_not create_gretap('tap2')

    expect(chef_run).to run_execute('ip link add tap1 type gretap remote 192.168.0.1 local 192.168.0.10')
    expect(chef_run).to run_execute('ip addr add 10.1.0.1/24 dev tap1')
    expect(chef_run).to run_execute('ip link set tap1 up')

    expect(chef_run).to create_server_interface('node1_tap1').with(
      hostname: 'node1',
      if_name: 'tap1',
      remote_address: '192.168.0.1',
      local_address: '192.168.0.10',
      virtual_address: '10.1.0.1',
      virtual_prefix: 24
    )
  end
end
