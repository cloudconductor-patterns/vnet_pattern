#
# Cookbook Name:: openvswitch
# Spec:: install_package_spec
#
# Copyright 2015, TIS.inc
#
# All rights reserved - Do Not Redistribute
#

require_relative '../spec_helper'

describe 'openvswitch::install_package' do
  let(:chef_run) { ChefSpec::SoloRunner.new }

  before do
    chef_run.converge(described_recipe)
  end

  it 'installs the openvswitch package' do
    expect(chef_run).to install_package('openvswitch')
  end

  it 'start the openvswitch service' do
    expect(chef_run).to start_service('openvswitch')
  end
end
