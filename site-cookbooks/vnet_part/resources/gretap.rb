#
# Cookbook Name:: vnet_part
# Resource:: gretap
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

attribute :remote_addr,
          kind_of: String,
          required: true,
          regex: [/^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$/]

attribute :local_addr,
          kind_of: String,
          default: nil,
          regex: [/^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$/]

attribute :virtual_addr,
          kind_of: String,
          default: nil,
          regex: [/^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+\/[0-9]+$/]
