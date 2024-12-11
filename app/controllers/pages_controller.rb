# frozen_string_literal: true

# Proxy Cloud.gov pages content at the root of the application
class PagesController < ApplicationController
  include ReverseProxy::Controller
  # We must remove this for proxy of JS assets to be loaded by the browser
  protect_from_forgery except: :assets

  # TODO: When launched, the cloud.gov pages need to move off the www.challenge.gov domain
  # and these constants will need to be updated. The will be similar to the commented out versions
  # and likely based on content.challenge.gov
  DOMAIN = "federalist-2c628203-05c2-48ab-8f87-3eda79380559.sites.pages.cloud.gov"
  HOST = "https://federalist-2c628203-05c2-48ab-8f87-3eda79380559.sites.pages.cloud.gov"
  BASE_URL = "/preview/gsa/challenges-and-prizes/staging/"
  # DOMAIN = "www.challenge.gov".freeze
  # HOST = "https://www.challenge.gov".freeze
  # BASE_URL = "/".freeze

  def index
    path = "#{BASE_URL}#{params[:path]}/"
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
      path = "#{HOST}#{BASE_URL}assets/#{params[:path]}.#{params[:ext]}.js"
      response = Faraday.get(path)
      send_data(response.body, type: 'application/javascript')
    else
      path = "#{BASE_URL}assets/#{params[:path]}.#{params[:ext]}"
      reverse_proxy(HOST, path:, reset_accept_encoding: true, headers: { host: DOMAIN })
    end
  end

  def root
    path = BASE_URL
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
    parsed_html = html.gsub("https://challenge.gov/", "/")
    parsed_html = parsed_html.gsub(HOST, "/")
    if BASE_URL.length > 1
      parsed_html = parsed_html.gsub(BASE_URL, "/")
    end
    # rubocop:disable Rails/OutputSafety
    parsed_html.html_safe
    # rubocop:enable Rails/OutputSafety
  end
end
