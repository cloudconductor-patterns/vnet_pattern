#
# Cookbook Name:: openvswitch
# Attributes:: default
#
# Copyright 2015, TIS Inc.
#
# All rights reserved - Do Not Redistribute
#

default['openvswitch']['install_method'] = 'source'
default['openvswitch']['version'] = '2.3.1'

default['openvswitch']['build_user'] = 'ovswitch'
