require 'faraday'

if ENV['LOCAL_PROXY']
  proxy_options = {
    uri: ENV['LOCAL_PROXY']
  }
  Faraday.default_connection = Faraday.new(proxy: proxy_options)
end
