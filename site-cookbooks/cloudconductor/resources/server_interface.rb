#
# Cookbook Name:: cloudconductor
# Resource:: server_interface
#
# Copyright 2015, TIS Inc.
#
# All rights reserved - Do Not Redistribute
#

actions :create, :delete
default_action :create

attribute :name,
          kind_of: String,
          name_attribute: true

attribute :hostname,
          kind_of: String,
          required: true

attribute :if_name,
          kind_of: String,
          required: true

attribute :type,
          kind_of: String,
          default: 'gretap'

attribute :network,
          kind_of: String

attribute :security_groups,
          kind_of: Array

attribute :remote_address,
          kind_of: String,
          regex: [/^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$/]

attribute :local_address,
          kind_of: String,
          regex: [/^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$/]

attribute :virtual_address,
          kind_of: String,
          default: nil,
          regex: [/^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$/]

attribute :virtual_prefix,
          kind_of: Integer

attribute :uuid,
          kind_of: String,
          regex: [/^if-.+$/]

attribute :hwaddr,
          kind_of: String,
          regex: [/^[0-9a-fA-F]+:[0-9a-fA-F]+:[0-9a-fA-F]+:[0-9a-fA-F]+$/]

attribute :port_name,
          kind_of: String
