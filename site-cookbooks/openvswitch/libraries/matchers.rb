#
# Cookbook Name:: openvswitch
# Library:: matchers
#
# Copyright 2015, TIS.inc
#
# All rights reserved - Do Not Redistribute
#

if defined?(ChefSpec)

  def create_openvswitch(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:openvswitch, :create, resource_name)
  end

  def up_openvswitch(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:openvswitch, :up, resource_name)
  end

  def down_openvswitch(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:openvswitch, :down, resource_name)
  end

  def restart_openvswitch(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:openvswitch, :restart, resource_name)
  end

  def delete_openvswitch(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:openvswitch, :delete, resource_name)
  end

  def create_openvswitch_port(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:openvswitch_port, :create, resource_name)
  end

  def delete_openvswitch_port(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:openvswitch_port, :delete, resource_name)
  end
end
