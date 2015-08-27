require 'net/http'
require 'json'
require 'base64'
require 'active_support'
require 'net/http'
require 'uri'
require 'cgi'

module ConsulParameters
  def read
    parameters = {}
    begin
      consul_secret_key = ENV['CONSUL_SECRET_KEY'].nil? ? '' : CGI.escape(ENV['CONSUL_SECRET_KEY'])
      response = Net::HTTP.get URI.parse("http://localhost:8500/v1/kv/cloudconductor/parameters?token=#{consul_secret_key}")
      response_hash = JSON.parse(response, symbolize_names: true).first
      parameters_json = Base64.decode64(response_hash[:Value])
      parameters = JSON.parse(parameters_json, symbolize_names: true)
    rescue => exception
      p exception.message
    end
    parameters
  end

  def read_servers
    begin
      servers = {}
      consul_secret_key = ENV['CONSUL_SECRET_KEY'].nil? ? '' : CGI.escape(ENV['CONSUL_SECRET_KEY'])
      response = Net::HTTP.get URI.parse("http://localhost:8500/v1/kv/cloudconductor/servers?recurse&token=#{consul_secret_key}")
      JSON.parse(response, symbolize_names: true).each do |response_hash|
        key = response_hash[:Key]
        next if key == 'cloudconductor/servers'
        hostname = key.slice(%r{cloudconductor/servers/(?<hostname>[^/]*)}, 'hostname')
        server_info_json = Base64.decode64(response_hash[:Value])
        servers[hostname] = JSON.parse(server_info_json, symbolize_names: true)
      end
    rescue
      servers = {}
    end
    servers
  end

  def kvs_keys(prefix)
    consul_secret_key = ENV['CONSUL_SECRET_KEY'].nil? ? '' : CGI.escape(ENV['CONSUL_SECRET_KEY'])
    response = Net::HTTP.get URI.parse("http://localhost:8500/v1/kv/#{prefix}?keys&token=#{consul_secret_key}")
    ret = JSON.parse(response, symbolize_names: true)
    ret || []
  end

  def kvs_get(key)
    consul_secret_key = ENV['CONSUL_SECRET_KEY'].nil? ? '' : CGI.escape(ENV['CONSUL_SECRET_KEY'])
    response = Net::HTTP.get URI.parse("http://localhost:8500/v1/kv/#{key}?raw&token=#{consul_secret_key}")
    ret = JSON.parse(response, symbolize_names: true)
    ret || {}
  end

  def read_networks
    networks = {}
    begin
      kvs_keys('cloudconductor/networks/').each do |key|
        next if key == 'cloudconductor/networks'
        hostname = key.slice(%r{#{prefix}/(?<hostname>[^/]*)}, 'hostname')
        if hostname == 'base'
          data = kvs_get(key)
          networks['base'] = data
          next
        end
        ifname = key.slice(%r{#{prefix}/#{hostname}/(?<ifname>[^/]*)}, 'ifname')
        data = kvs_get(key)
        networks[hostname] ||= {}
        networks[hostname][ifname] = data
      end
    rescue => exception
      p exception.message
    end
    networks
  end
end
