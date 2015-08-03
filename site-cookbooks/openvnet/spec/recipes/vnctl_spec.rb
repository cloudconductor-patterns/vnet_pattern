#
# Cookbook Name:: openvnet
# Spec:: vnctl_spec
#
# Copyright 2015, TIS.inc
#
# All rights reserved - Do Not Redistribute
#

require_relative '../spec_helper'

describe 'openvnet::vnctl' do
  let(:chef_run) { ChefSpec::SoloRunner.new }

  before do
    chef_run.converge(described_recipe)
  end

  it 'include common recipe' do
    expect(chef_run).to include_recipe('openvnet::common')
  end

  it 'installs openvnet-vnctl package' do
    expect(chef_run).to install_package('openvnet-vnctl')
  end
end
