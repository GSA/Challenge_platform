# frozen_string_literal: true

# Proxy Cloud.gov pages content at the root of the application
class PagesController < ApplicationController
  include ReverseProxy::Controller
  # We must remove this for proxy of JS assets to be loaded by the browser
  protect_from_forgery except: :assets

  # TODO: When launched, the cloud.gov pages need to move off the www.challenge.gov domain
  DOMAIN = Rails.configuration.static_site_interop.fetch(:domain)
  HOST = Rails.configuration.static_site_interop.fetch(:host)
  BASE_URL = Rails.configuration.static_site_interop.fetch(:base_url)

  def index
    path = "#{BASE_URL}/#{params[:path]}/"
    reverse_proxy(HOST, path:, reset_accept_encoding: true, headers: { host: DOMAIN }) do |config|
      config.on_missing do |_code, _response|
        redirect_to "/dashboard"
        return true
      end

      config.on_response do |_code, response|
        response.body = rewrite_links(response.body)
      end
    end
  end

  def assets
    if params[:ext] == "min"
      path = "#{HOST}#{BASE_URL}/assets/#{params[:path]}.#{params[:ext]}.js"
      response = Faraday.get(path)
      send_data(response.body, type: 'application/javascript')
    else
      path = "#{BASE_URL}/assets/#{params[:path]}.#{params[:ext]}"
      reverse_proxy(HOST, path:, reset_accept_encoding: true, headers: { host: DOMAIN })
    end
  end

  def root
    path = "#{BASE_URL}/"
    reverse_proxy(HOST, path:, reset_accept_encoding: true, headers: { host: DOMAIN }) do |config|
      config.on_response do |_code, response|
        if response.body.present?
          response.body = rewrite_links(response.body)
        end
      end
    end
  end

  private

  def rewrite_links(html)
    parsed_html = html.gsub(HOST, "/")
    if BASE_URL.length > 1
      parsed_html = parsed_html.gsub(BASE_URL, "")
    end
    # delete the data-public-url attribute from the react app element to send requests through rails proxy
    parsed_html = parsed_html.sub(/(<div id="challenge-gov-react-app".+)(data-public-url=[^ ]+)/, '\1')

    # rubocop:disable Rails/OutputSafety
    parsed_html.html_safe
    # rubocop:enable Rails/OutputSafety
  end
end
