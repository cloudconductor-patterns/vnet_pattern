#
# Cookbook Name:: openvswitch
# Resource:: port
#
# Copyright 2015, TIS.inc
#
# All rights reserved - Do Not Redistribute
#

actions :create, :delete
default_action :create

attribute :bridge,
          kind_of: String,
          required: true

attribute :port,
          kind_of: String,
          name_attribute: true
