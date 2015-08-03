#
# Cookbook Name:: vnet_part
# Spec:: recipe/vnet_configure_spec
#
# Copyright 2015, TIS Inc
#
# All rights reserved - Do Not Redistribute
#

require_relative '../spec_helper'

describe 'vnet_part::vnet_configure' do
  # let(:chef_run) { ChefSpec::SoloRunner.new(step_into: %w(cloudconductor_servers)) }
  let(:chef_run) { ChefSpec::SoloRunner.new }

  before do
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

    chef_run.converge(described_recipe)
  end

  def create_vnet_edge(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:cloudconductor_vnet_edge, :create, resource_name)
  end

  def create_server_interface(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:cloudconductor_server_interface, :create, resource_name)
  end

  it 'create vna definitions' do
    expect(chef_run).to create_vnet_edge('edge1').with(
      vna_id: 'vna1',
      hwaddr: '02:00:01:01:00:01',
      datapath_id: '0x00020001010001'
    )
  end

  it 'create interface definitions' do
    expect(chef_run).to create_server_interface('tapn1').with(
      hostname: 'node1',
      uuid: 'if-n1',
      type:  'gretap',
      ipaddr: '10.1.0.1/24'
    )
  end

  describe 'some nodes' do
    before do
      chef_run.node.set['cloudconductor']['servers'] = {
        node1: {
          private_ip: '192.168.0.11',
          roles: 'web',
          pattern: 'pattern_name'
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
      chef_run.converge(described_recipe)
    end

    it 'create interface definitions' do
      expect(chef_run).to create_server_interface('tapn1').with(
        hostname: 'node1',
        uuid: 'if-n1',
        type: 'gretap',
        ipaddr: '10.1.0.1/24'
      )

      expect(chef_run).to create_server_interface('tapn2').with(
        hostname: 'node2',
        uuid: 'if-n2',
        type: 'gretap',
        ipaddr: '10.1.0.2/24'
      )

      expect(chef_run).to create_server_interface('tapn3').with(
        hostname: 'node3',
        uuid: 'if-n3',
        type: 'gretap',
        ipaddr: '10.1.0.3/24'
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
end
