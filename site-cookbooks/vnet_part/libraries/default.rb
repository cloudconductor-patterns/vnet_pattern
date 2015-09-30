#
# Cookbook Name:: vnet_part
# Library:: default
#
# Copyright 2015, TIS Inc.
#
# All rights reserved - Do Not Redistribute
#

module CloudConductor
  module VnetPartHelper
    include CloudConductor::CommonHelper

    def sv_nodes
      all_servers.reject do |_, s|
        s['roles'].include?('vna') || s['roles'].include?('vnmgr')
      end
    end

    def node_servers
      sv_nodes.map do |hostname, server_info|
        server_info['hostname'] = hostname
        server_info.with_indifferent_access
      end
    end

    def host_at_ipaddress(ipaddress)
      all_servers.select do |_, v|
        v['private_ip'] == ipaddress
      end
    end

    def host_info
      Chef::Log.debug 'called get_host_info'
      Chef::Log.debug "local = #{node['ipaddress']}"

      if node['vnet_part']['node_ref']
        node_name = node['vnet_part']['node_ref']

        result = host_at_name(node_name)
      else
        result = host_at_ipaddress(node['ipaddress'])
      end

      result = result.map do |hostname, server_info|
        server_info['hostname'] = hostname
        server_info.with_indifferent_access
      end
      result = result.first
      result ||= {}

      Chef::Log.debug "result => #{result}"
      result
    end

    def set_network_current_addr(network, address)
      node.set['vnet_part']['networks']['networks'][network]['current_addr'] = address
    end

    def networks_base
      key = node['vnet_part']['keys']['networks']['base']
      result = ::Chef::Mixin::DeepMerge.deep_merge(result, kvs_get(key))
      result || {}
    end

    #
    # consul < attributes
    def network_conf
      result = node['vnet_part']['networks'].to_hash if node['vnet_part']['networks']

      result = ::Chef::Mixin::DeepMerge.deep_merge(result, networks_base)

      node.set['vnet_part']['networks'] = result

      result || {}
    end

    def network_address(network_name)
      nwcfg = network_conf['networks'][network_name]
      nwcfg['ipv4_network'] || node['vnet_part']['config']['network']['virtual']['addr']
    end

    def network_prefix(network_name)
      nwcfg = network_conf['networks'][network_name]
      nwcfg['ipv4_prefix'] || node['vnet_part']['config']['network']['virtual']['mask']
    end

    def current_address(network_name)
      nwcfg = network_conf['networks'][network_name]
      nwcfg['current_addr'] || network_address(network_name)
    end

    def vna_config(hostname)
      key = "cloudconductor/networks/#{hostname}/vna"
      kvs_get(key)
    end

    def load_current_interfaces(svinfo)
      prefix = "#{node['vnet_part']['keys']['networks']['prefix']}#{svinfo['hostname']}/"
      data = CloudConductor::ConsulClient::KeyValueStore.keys(prefix)
      keys = JSON.parse(data) if data && data.length > 0

      current_interfaces = {}

      keys.each do |key|
        ifname = key.slice(Regexp.new("#{prefix}(?<if_name>[^/]*)"), 'if_name')
        current_interfaces[ifname] = kvs_get(key)
      end if keys

      current_interfaces
    end

    def gretap_interfaces(svinfo)
      new_interfaces = {}

      network_conf['servers'].each do |_name, svcfg|
        if svcfg['role'] == 'all' || svcfg['role'] == 'default'
          ::Chef::Mixin::DeepMerge.deep_merge!(svcfg['interfaces'], new_interfaces)
        end
        if svcfg['role'] && svinfo['roles'].include?(svcfg['role'])
          ::Chef::Mixin::DeepMerge.deep_merge!(svcfg['interfaces'], new_interfaces)
        end
      end

      new_interfaces.each do |_ifname, ifcfg|
        ifcfg['update'] = true
      end

      current_interfaces = load_current_interfaces(svinfo)

      result = ::Chef::Mixin::DeepMerge.deep_merge(new_interfaces, current_interfaces)

      result.reject do |ifname, _ifcfg|
        ifname == 'vna'
      end
    end
  end
end
