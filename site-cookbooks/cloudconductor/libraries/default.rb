# -*- coding: utf-8 -*-
# Copyright 2014 TIS Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'active_support'
require 'active_support/core_ext'

module CloudConductor
  module CommonHelper
    def server_info(role)
      if node['cloudconductor'] && node['cloudconductor']['servers']
        servers = node['cloudconductor']['servers'].to_hash.select do |_, s|
          s['roles'].include?(role)
        end
        result = servers.map do |hostname, server_info|
          server_info['hostname'] = hostname
          server_info.with_indifferent_access
        end
      else
        result = []
      end
      result
    end

    def all_servers
      if node['cloudconductor'] && node['cloudconductor']['servers']
        result = node['cloudconductor']['servers'].to_hash
      else
        result = {}
      end
      result
    end

    def host_info
      if node['cloudconductor'] && node['cloudconductor']['servers']
        servers = node['cloudconductor']['servers'].to_hash.select do |hostname, _info|
          hostname == node['hostname']
        end
        result = servers.map do |hostname, server_info|
          server_info['hostname'] = hostname
          server_info.with_indifferent_access
        end
      else
        result = []
      end
      result
    end

    def platform_pattern
      if node['cloudconductor'] && node['cloudconductor']['patterns']
        patterns = node['cloudconductor']['patterns'].to_hash.select do |_, info|
          info['type'] == 'platform'
        end
        result = patterns.map do |name, info|
          info['name'] = name
          info.with_indifferent_access
        end
        result = result.first
      else
        result = {}
      end
      result
    end

    def optional_patterns
      if node['cloudconductor'] && node['cloudconductor']['patterns']
        patterns = node['cloudconductor']['patterns'].to_hash.select do |_, info|
          info['type'] == 'optional'
        end
        result = patterns.map do |name, info|
          info['name'] = name
          info.with_indifferent_access
        end
      else
        result = []
      end
      result
    end

    def patterns_dir
      node['cloudconductor']['config']['patterns_dir']
    end
  end
end
