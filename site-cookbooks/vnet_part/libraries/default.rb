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
    def node_servers
      servers = all_servers.reject do |_, s|
        s['roles'].include?('vna') || s['roles'].include?('vnmgr')
      end

      result = servers.map do |hostname, server_info|
        server_info['hostname'] = hostname
        server_info.with_indifferent_access
      end
      result
    end

    def find_server_from_name(hostname)
      result = {}
      result = node['cloudconductor']['servers'][hostname].to_hash if node['cloudconductor']['servers'][hostname]
      result['hostname'] = hostname

      result
    end

    def find_server_from_ipaddress(ipaddress)
      all_servers = node['cloudconductor']['servers']
      servers = all_servers.to_hash.select do |_, v|
        v['private_ip'] == ipaddress
      end

      result = servers.map do |hostname, info|
        info['hostname'] = hostname
        info
      end

      result.first
    end

    def host_info
      Chef::Log.debug 'called get_host_info'
      Chef::Log.debug "local = #{node['ipaddress']}"

      if node['vnet_part']['node_ref']
        node_name = node['vnet_part']['node_ref']

        result = find_server_from_name(node_name)
      else
        result = find_server_from_ipaddress(node['ipaddress'])
      end
      Chef::Log.debug "result => #{result}"
      result
    end

    def set_network_current_addr(network, address)
      node.set['vnet_part']['networks']['networks'][network]['current_addr'] = address
    end

    def network_conf
      key = node['vnet_part']['keys']['networks']['base']

      result = node['vnet_part']['networks'].to_hash if node['vnet_part']['networks']

      data = CloudConductor::ConsulClient::KeyValueStore.get(key)
      result = ::Chef::Mixin::DeepMerge.deep_merge(result, JSON.parse(data)) if data && data.length > 0

      node.set['vnet_part']['networks'] = result

      result = {} unless result

      result
    end

    def load_current_interfaces(svinfo)
      prefix = "#{node['vnet_part']['keys']['networks']['prefix']}#{svinfo['hostname']}/"
      data = CloudConductor::ConsulClient::KeyValueStore.keys(prefix)
      keys = JSON.parse(data) if data && data.length > 0

      current_interfaces = {}

      keys.each do |key|
        ifname = key.slice(Regexp.new("#{prefix}(?<if_name>[^/]*)"), 'if_name')
        data = CloudConductor::ConsulClient::KeyValueStore.get(key)

        current_interfaces[ifname] = JSON.parse(data) if data && data.length > 0
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
