require 'net/http'
require 'addressable/uri'
require 'json'

require File.expand_path(File.join(File.dirname(__FILE__), 'jsonrpc', 'version'))
require File.expand_path(File.join(File.dirname(__FILE__), 'jsonrpc', 'exceptions'))

module JsonRPC

  class Client

    def initialize(url)
      @address    = Addressable::URI.parse(url)
    end

    def request(method, params)
      result = {}
      params ||= {}
      h = {
        "Content-Type" => "application/json",
        'User-Agent' => 'Ruby JSON-RPC Client 1.1',
        'Accept' => 'application/json'
      }
      Net::HTTP.start(@address.host, @address.port) do |connection|
        result = JSON.parse(connection.post(@address.path,
                                            {:method => method.to_s, :params => params, :version => '1.1'}.to_json,
                                            h).body)
      end
      if error = result["error"]
        raise JsonRPCError, error["message"]
      end
      result
    end

  end

end
