#
# Cookbook Name:: cloudconductor
# Resource:: vnet_edge
#
# Copyright 2015, TIS Inc.
#
# All rights reserved - Do Not Redistribute
#

actions :create
default_action :create

attribute :hostname,
          kind_fo: String,
          name_attribute: true

attribute :vna_id,
          kind_of: String,
          required: true

attribute :hwaddr,
          kind_of: String,
          required: true

attribute :datapath_id,
          kind_of: String,
          required: true

attribute :bridge,
          kind_of: String
