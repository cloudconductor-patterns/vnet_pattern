#
# Cookbook Name:: openvswitch
# Recipe:: install_source
#
# Copyright 2015, TIS Inc.
#
# All rights reserved - Do Not Redistribute
#

version = node['openvswitch']['version']
ovs_name = "openvswitch-#{version}"

packages = %w(gcc make automake rpm-build redhat-rpm-config python-devel openssl-devel kernel-devel kernel-debug-devel kernel-abi-whitelists wget)

packages.each do |pkgname|
  package pkgname
end

build_user = node['openvswitch']['build_user']

user build_user do
  action :create
end

directory "/home/#{build_user}/rpmbuild/" do
  action :create
  owner build_user
  mode '0755'
end

directory "/home/#{build_user}/rpmbuild/SOURCES/" do
  action :create
  owner build_user
  mode '0755'
end

cookbook_file "/home/#{build_user}/rpmbuild/SOURCES/#{ovs_name}.patch" do
  source "#{version}.patch"
  owner build_user
end

cookbook_file "/home/#{build_user}/build.sh" do
  source 'build.sh'
  owner build_user
  mode '0755'
end

bash 'build' do
  cwd "/home/#{build_user}"
  code <<-EOF
  cat ./build.sh | su - #{build_user} -c "bash -s -- -v #{version}"
EOF
end

bash 'install' do
  code <<-EOF
  output=$(yum list installed | grep openvswitch )
  status=$?
  if [ $status -ne 0 ]; then
    yum install -y /home/#{build_user}/rpmbuild/RPMS/**/kmod-#{ovs_name}-1*.rpm
    yum install -y /home/#{build_user}/rpmbuild/RPMS/**/#{ovs_name}-1*.rpm
  fi
EOF
end

service 'openvswitch' do
  action :start
end
