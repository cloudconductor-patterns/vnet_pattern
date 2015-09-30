#
# Cookbook Name:: openvnet
# Resource:: network
#
# Copyright 2015, TIS.inc
#
# All rights reserved - Do Not Redistribute
#

actions :create
default_action :create

attribute :uuid,
          kind_of: String,
          name_attribute: true

attribute :display_name,
          kind_of: String

attribute :ipv4_network,
          kind_of: String,
          required: true

attribute :ipv4_prefix,
          kind_of: Integer

attribute :domain_name,
          kind_of: String

attribute :mode,
          kind_of: String
