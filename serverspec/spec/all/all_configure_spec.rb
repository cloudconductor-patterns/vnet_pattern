require_relative '../spec_helper.rb'

if !ENV['role'].include?('vna') && !ENV['role'].include?('vnmgr')
  describe 'connect to each instance through a virtual network' do
    property[:networks].each do |servername, ports|
      next if servername == 'base'
      ports.each do |_port, settings|
        describe host(settings[:virtual_address]) do
          it { should be_reachable }
        end
      end
    end
  end
end
