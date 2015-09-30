#
# Cookbook Name:: openvnet
# Library:: matchers
#
# Copyright 2015, TIS.inc
#
# All rights reserved - Do Not Redistribute
#

if defined?(ChefSpec)

  def create_openvnet_common(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:openvnet_common, :create, resource_name)
  end

  def create_openvnet_vna(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:openvnet_vna, :create, resource_name)
  end

  def create_openvnet_datapath(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:openvnet_datapath, :create, resource_name)
  end

  def create_openvnet_network(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:openvnet_network, :create, resource_name)
  end

  def create_openvnet_interface(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:openvnet_interface, :create, resource_name)
  end

  def create_openvnet_security_group(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:openvnet_security_group, :create, resource_name)
  end
end
