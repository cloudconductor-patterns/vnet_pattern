#
# Cookbook Name:: openvnet
# Resource:: common
#
# Copyright 2015, TIS Inc.
#
# All rights reserved - Do Not Redistribute
#

actions :create
default_action :create

attribute :registry,
          kind_of: Hash

attribute :database,
          kind_of: Hash

attribute :cookbook,
          kind_of: String,
          default: 'openvnet'
