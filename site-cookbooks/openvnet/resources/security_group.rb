#
# Cookbook Name:: openvnet
# Resource:: security_group
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

attribute :rules,
          kind_of: [String, Array]

attribute :interfaces,
          kind_of: Array
