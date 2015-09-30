require_relative '../spec_helper.rb'

if !ENV['ROLE'].include?('vna') && !ENV['ROLE'].include?('vnmgr')
  describe 'connect to each instance through a virtual network' do
    property[:networks].each do |servername, ports|
      next if servername == 'base'
      ports.each do |portname, settings|
        next if portname == 'vna'
        describe host(settings[:virtual_address]) do
          it { should be_reachable }
        end
      end
    end
  end
end
