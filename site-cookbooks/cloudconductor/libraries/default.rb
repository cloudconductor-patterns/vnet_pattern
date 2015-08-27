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
      servers(role).map do |hostname, server_info|
        server_info['hostname'] = hostname
        server_info.with_indifferent_access
      end
    end

    def all_servers
      if node['cloudconductor'] && node['cloudconductor']['servers']
        result = node['cloudconductor']['servers'].to_hash
      else
        result = {}
      end
      result
    end

    def servers(role)
      all_servers.select do |_, s|
        s['roles'].include?(role)
      end
    end

    def host_info
      result = host_at_name(node['hostname']).map do |hostname, server_info|
        server_info['hostname'] = hostname
        server_info.with_indifferent_access
      end
      result.first || {}
    end

    def host_at_name(name)
      all_servers.select do |hostname, _info|
        hostname == name
      end
    end

    def platform_pattern
      result = patterns('platform').map do |name, info|
        info['name'] = name
        info.with_indifferent_access
      end
      result.first || {}
    end

    def optional_patterns
      patterns('optional').map do |name, info|
        info['name'] = name
        info.with_indifferent_access
      end
    end

    def all_patterns
      if node['cloudconductor'] && node['cloudconductor']['patterns']
        result = node['cloudconductor']['patterns'].to_hash
      else
        result = {}
      end
      result
    end

    def patterns(type)
      all_patterns.select do |_, info|
        info['type'] == type
      end
    end

    def patterns_dir
      node['cloudconductor']['config']['patterns_dir']
    end

    def pattern_path(pattern_name)
      File.join(patterns_dir, pattern_name)
    end

    def platform_pattern_path
      pattern_path(platform_pattern['name'])
    end
  end
end
