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

packages = %w(gcc make automake rpm-build redhat-rpm-config python-devel openssl-devel kernel-devel kernel-debug-devel)

packages.each do |pkgname|
  package pkgname
end

directory '/root/rpmbuild/SOURCES' do
  recursive true
  action :create
end

remote_file "/root/rpmbuild/SOURCES/#{ovs_name}.tar.gz" do
  source "http://openvswitch.org/releases/#{ovs_name}.tar.gz"
end

bash 'unpack' do
  cwd '/root/rpmbuild/SOURCES'
  code <<-EOF
  if [ -d #{ovs_name} ]; then
    rm -r -f #{ovs_name}
  fi
  tar xfz #{ovs_name}.tar.gz
EOF
end

cookbook_file "/root/rpmbuild/SOURCES/#{ovs_name}.patch" do
  source "#{version}.patch"
end

cookbook_file "/root/rpmbuild/SOURCES/#{ovs_name}-kmod-spec.patch" do
  source "#{version}-kmod-spec.patch"
end

bash 'build' do
  cwd "/root/rpmbuild/SOURCES/#{ovs_name}"
  code <<-EOF
  rpmbuild -bb --without check rhel/openvswitch.spec
  cp rhel/openvswitch-kmod.files ../
  patch -p1 < ../#{ovs_name}-kmod-spec.patch
  rpmbuild -bb rhel/openvswitch-kmod-rhel6.spec
EOF
end

bash 'install' do
  code <<-EOF
  yum install -y /root/rpmbuild/RPMS/**/kmod-#{ovs_name}-1*.rpm
  yum install -y /root/rpmbuild/RPMS/**/#{ovs_name}-1*.rpm
EOF
end

service 'openvswitch' do
  action :start
end
