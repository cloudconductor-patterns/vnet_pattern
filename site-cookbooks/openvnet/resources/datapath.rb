#
# Cookbook Name:: openvnet
# Resource:: datapath
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

attribute :datapath_id,
          kind_of: String,
          required: true

attribute :node_id,
          kind_of: String,
          required: true
