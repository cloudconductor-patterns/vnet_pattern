#
# Cookbook Name:: openvnet
# Resource:: interface
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

attribute :ingress_filtering,
          kind_of: [TrueClass, FalseClass],
          equal_to: [true, false]

attribute :routing,
          kind_of: [TrueClass, FalseClass],
          equal_to: [true, false]

attribute :route_translation,
          kind_of: [TrueClass, FalseClass],
          equal_to: [true, false]

attribute :datapath,
          kind_of: String

attribute :network,
          kind_of: String

attribute :mac_addr,
          kind_of: String

attribute :ipv4_addr,
          kind_of: String,
          regex: [/^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$/]

attribute :port_name,
          kind_of: String

attribute :mode,
          kind_of: String
