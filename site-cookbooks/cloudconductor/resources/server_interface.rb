#
# Cookbook Name:: cloudconductor
# Resource:: server_interface
#
# Copyright 2015, TIS Inc.
#
# All rights reserved - Do Not Redistribute
#

actions :create, :update, :delete
default_action :create

attribute :hostname,
          kind_of: String,
          required: true

attribute :ifname,
          kind_of: String,
          name_attribute: true

attribute :uuid,
          kind_of: String,
          regex: [/^if-.+$/]

attribute :type,
          kind_of: String,
          default: 'gretap'

attribute :ipaddr,
          kind_of: String,
          default: nil,
          regex: [/^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+\/[0-9]+$/]
