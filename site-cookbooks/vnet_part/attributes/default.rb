#
# Cookbook Name:: vnet_part
# Attribute:: default
#
# Copyright 2015, TIS Inc.
#
# All rights reserved - Do Not Redistribute
#

default['vnet_part']['node_ref'] = nil

default['vnet_part']['config']['network']['virtual']['addr'] = '10.1.0.0'
default['vnet_part']['config']['network']['virtual']['mask'] = 24

default['vnet_part']['config']['patterns_dir'] = '/opt/cloudconductor/patterns/'

default['vnet_part']['keys']['networks']['base'] = 'cloudconductor/networks/base'
default['vnet_part']['keys']['networks']['prefix'] = 'cloudconductor/networks/'
