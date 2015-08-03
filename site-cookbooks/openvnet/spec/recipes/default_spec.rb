#
# Cookbook Name:: openvnet
# Spec:: default_spec
#
# Copyright 2015, TIS.inc
#
# All rights reserved - Do Not Redistribute
#

require_relative '../spec_helper'

describe 'openvnet::default' do
  let(:chef_run) { ChefSpec::SoloRunner.new }

  before do
    chef_run.converge(described_recipe)
  end

  it 'include vnmgr recipe' do
    expect(chef_run).to include_recipe('openvnet::vnmgr')
  end

  it 'include webapi recipe' do
    expect(chef_run).to include_recipe('openvnet::webapi')
  end

  it 'include vna recipe' do
    expect(chef_run).to include_recipe('openvnet::vna')
  end
end
