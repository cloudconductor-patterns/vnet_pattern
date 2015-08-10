#
# Cookbook Name:: vnet_part
# Spec:: vnet_dataset_spec
#
# Copyright 2015, TIS.inc
#
# All rights reserved - Do Not Redistribute
#

require_relative '../spec_helper'

describe 'vnet_part::vnet_dataset' do
  let(:chef_run) { ChefSpec::SoloRunner.new(step_into: %w(openvnet_interface)) }

  before do
    chef_run.node.set['cloudconductor']['servers'] = {
      edge1: {
        private_ip: '192.168.0.1',
        roles: %w(vna vnmgr),
        vna: {
          id: 'vna1',
          hwaddr: '02:99:99:01:00:01',
          datapath_id: '0x00029999010001'
        }
      },
      node1: {
        private_ip: '192.168.0.11',
        roles: 'web',
        interfaces: {
          gre_n1: {
            type: 'gretap',
            uuid: 'if-n1',
            hwaddr: '02:00:99:01:00:01',
            ipaddr: '10.1.0.1/24'
          }
        }
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

    chef_run.converge(described_recipe)
  end

  it do
    expect(chef_run).to create_openvnet_datapath('dp-01').with(
      datapath_id: '0x00029999010001',
      node_id: 'vna1'
    )
  end

  it do
    expect(chef_run).to create_openvnet_network('nw-1').with(
      ipv4_network: '10.1.0.0',
      ipv4_prefix: 24,
      mode: 'virtual'
    )
  end

  it do
    expect(chef_run).to create_openvnet_interface('if-n1').with(
      datapath: 'dp-01',
      network: 'nw-1',
      ipv4_addr: '10.1.0.1',
      mac_addr: '02:00:99:01:00:01',
      port_name: 'gre_n1'
    )

    cmdstr = 'vnctl interfaces add'
    cmdstr << ' --uuid if-n1'
    cmdstr << ' --owner-datapath-uuid dp-01'
    cmdstr << ' --network-uuid nw-1'
    cmdstr << ' --mac-address 02:00:99:01:00:01'
    cmdstr << ' --ipv4-address 10.1.0.1'
    cmdstr << ' --port-name gre_n1'

    expect(chef_run).to run_execute(cmdstr)
  end
end
