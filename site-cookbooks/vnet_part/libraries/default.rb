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
  end
end
