#
# Cookbook Name:: openvnet
# Resource:: vna
#
# Copyright 2015, TIS.inc
#
# All rights reserved - Do Not Redistribute
#

actions :create, :start, :stop
default_action :create

attribute :vna_id,
          kind_of: String,
          name_attribute: true

attribute :bridge,
          kind_of: String,
          default: 'br0'

attribute :datapath_id,
          kind_of: String,
          required: true

attribute :hwaddr,
          kind_of: String,
          required: true

attribute :host_addr,
          kind_of: String

attribute :public_addr,
          kind_of: String

attribute :port,
          kind_of: [String, Integer]

attribute :registry,
          kind_of: Hash

attribute :database,
          kind_of: Hash

attribute :service_start,
          kind_of: [TrueClass, FalseClass],
          equal_to: [true, false],
          default: 'true'

attribute :cookbook,
          kind_of: String,
          default: 'openvnet'
