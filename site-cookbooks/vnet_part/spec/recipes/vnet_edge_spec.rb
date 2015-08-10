#
# Cookbook Name:: vnet_part
# Spec:: vnet_edge_spec
#
# Copyright 2015, TIS.inc
#
# All rights reserved - Do Not Redistribute
#

require_relative '../spec_helper'

describe 'vnet_part::vnet_edge' do
  let(:chef_run) { ChefSpec::SoloRunner.new(step_into: %w(openvnet_vna openvswitch_port)) }

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
      edge2: {
        private_ip: '192.168.0.2',
        roles: 'vna',
        vna: {
          id: 'vna2',
          hwaddr: '02:99:99:01:00:02',
          datapath_id: '0x00029999010002'
        }
      }
    }

    chef_run.node.set['vnet_part']['node_ref'] = 'edge1'

    chef_run.converge(described_recipe)
  end

  it 'create vna1 resource' do
    chef_run.node.set['vnet_part']['node_ref'] = 'edge1'
    chef_run.converge(described_recipe)

    expect(chef_run).to create_openvnet_vna('vna1').with(
      hwaddr: '02:99:99:01:00:01',
      datapath_id: '0x00029999010001',
      registry: {
        'host' => '127.0.0.1',
        'port' => 6379
      }
    )

    expect(chef_run).to create_template('/etc/openvnet/vna.conf').with(
      source: 'vna.conf.erb',
      cookbook: 'openvnet',
      owner: 'root',
      group: 'root',
      mode: 0644,
      variables: {
        id: 'vna1',
        host: '127.0.0.1',
        public: nil,
        port: 9103
      }
    )
  end

  it 'create vna2 resource' do
    chef_run.node.set['vnet_part']['node_ref'] = 'edge2'
    chef_run.converge(described_recipe)

    expect(chef_run).to create_openvnet_vna('vna2').with(
      hwaddr: '02:99:99:01:00:02',
      datapath_id: '0x00029999010002',
      registry: {
        'host' => '192.168.0.1',
        'port' => 6379
      }
    )
  end

  describe 'create gretap' do
    before do
      chef_run.node.set['cloudconductor']['servers'] = {
        edge1: {
          private_ip: '192.168.0.1',
          roles: %w(vna vnmgr),
          vna: {
            id: 'vna1',
            hwaddr: '02:99:99:99:01:01',
            datapath_id: '0x00029999990101'
          }
        },
        edge2: {
          private_ip: '192.168.0.2',
          roles: 'vna',
          vna: {
            id: 'vna2'
          }
        },
        node1: {
          private_ip: '192.168.0.11',
          roles: 'web',
          interfaces: {
            tap1: {
              type: 'gretap'
            },
            tap2: {
              type: 'bridge'
            }
          }
        },
        node2: {
          private_ip: '192.168.0.12',
          roles: 'ap',
          interfaces: {
            tap3: {
              type: 'gretap'
            }
          }
        }
      }

      chef_run.node.set['vnet_part']['node_ref'] = 'edge1'

      chef_run.converge(described_recipe)
    end

    def create_gretap(resource_name)
      ChefSpec::Matchers::ResourceMatcher.new(:vnet_part_gretap, :create, resource_name)
    end

    it 'for sum nodes ' do
      expect(chef_run).to create_gretap('tap1').with(
        remote_addr: '192.168.0.11',
        local_addr: '192.168.0.1'
      )

      expect(chef_run).to_not create_gretap('tap2')

      expect(chef_run).to create_gretap('tap3').with(
        remote_addr: '192.168.0.12',
        local_addr: '192.168.0.1'
      )
    end

    it 'add port to bridge' do
      expect(chef_run).to create_openvswitch_port('tap1').with(
        bridge: 'br0'
      )

      expect(chef_run).to run_execute('ovs-vsctl add-port br0 tap1')

      expect(chef_run).to_not create_openvswitch_port('tap2')

      expect(chef_run).to_not run_execute('ovs-vsctl add-port br0 tap2')

      expect(chef_run).to create_openvswitch_port('tap3').with(
        bridge: 'br0'
      )

      expect(chef_run).to run_execute('ovs-vsctl add-port br0 tap3')
    end
  end
end
