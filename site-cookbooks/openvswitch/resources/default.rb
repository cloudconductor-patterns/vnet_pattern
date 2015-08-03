#
# Cookbook Name:: openvswitch
# Resource:: default
#
# Copyright 2015, TIS Inc.
#
# All rights reserved - Do Not Redistribute
#

actions :create, :up, :down, :restart, :delete
default_action :create

attribute :name,
          kind_of: String,
          name_attribute: true

attribute :cookbook,
          kind_of: String,
          default: 'openvswitch'

attribute :type,
          kind_of: String,
          default: 'OVSBridge'

attribute :onboot,
          kind_of: String,
          equal_to: %w(yes no),
          default: 'yes'

attribute :bootproto,
          kind_of: String,
          equal_to: %w(none static dhcp),
          default: 'none'

attribute :ipaddr,
          kind_of: String,
          default: nil

attribute :mask,
          kind_of: String,
          default: nil

attribute :ovs_extra,
          kind_of: String,
          default: nil
