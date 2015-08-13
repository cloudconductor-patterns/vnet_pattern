#
# Cookbook Name:: openvnet
# Attributes:: default
#
# Copyright 2015, TIS.inc
#
# All rights reserved - Do Not Redistribute
#

default['openvnet']['package']['repo']['file'] = 'https://raw.githubusercontent.com/axsh/openvnet/master/deployment/yum_repositories/stable/openvnet.repo'
default['openvnet']['third_party']['repo']['file'] = 'https://raw.githubusercontent.com/axsh/openvnet/master/deployment/yum_repositories/stable/openvnet-third-party.repo
'

default['openvnet']['vna']['datapath']['datapath_id'] = '0x020100010001'
default['openvnet']['vna']['datapath']['hwaddr'] = '02:01:00:01:00:01'

default['openvnet']['config']['registry']['host'] = '127.0.0.1'
default['openvnet']['config']['registry']['port'] = 6379
default['openvnet']['config']['database']['host'] = 'localhost'
default['openvnet']['config']['database']['port'] = '3306'
default['openvnet']['config']['database']['db_name'] = 'vnet'
default['openvnet']['config']['database']['username'] = 'root'
default['openvnet']['config']['database']['password'] = ''

default['openvnet']['config']['webapi']['host'] = '127.0.0.1'
default['openvnet']['config']['webapi']['public'] = nil
default['openvnet']['config']['webapi']['port'] = 9101

default['openvnet']['config']['vnmgr']['host'] = '127.0.0.1'
default['openvnet']['config']['vnmgr']['public'] = nil
default['openvnet']['config']['vnmgr']['port'] = 9102

default['openvnet']['config']['vna']['id'] = 'vna'
default['openvnet']['config']['vna']['host'] = '127.0.0.1'
default['openvnet']['config']['vna']['public'] = nil
default['openvnet']['config']['vna']['port'] = 9103

default['openvnet']['config']['vnctl']['webapi_protocol'] = 'http'
default['openvnet']['config']['vnctl']['webapi_uri'] = '127.0.0.1'
default['openvnet']['config']['vnctl']['webapi_port'] = '9090'
default['openvnet']['config']['vnctl']['webapi_version'] = '1.0'
default['openvnet']['config']['vnctl']['output_format'] = 'yml'
