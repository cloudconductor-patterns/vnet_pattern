require_relative '../spec_helper.rb'

describe package('redis') do
  it { should be_installed }
end

describe service('redis') do
  it { should be_enabled }
  it { should be_running }
end

describe package('mysql-server') do
  it { should be_installed }
end

describe service('mysqld') do
  it { should be_enabled }
  it { should be_running }
end

describe package('openvnet-vnmgr') do
  it { should be_installed }
end

describe package('openvnet-ruby') do
  it { should be_installed }
end

describe service('vnet-vnmgr') do
  it { should be_running }
end

describe package('openvnet-webapi') do
  it { should be_installed }
end

describe service('vnet-webapi') do
  it { should be_running }
end

describe package('openvnet-vnctl') do
  it { should be_installed }
end
