# frozen_string_literal: true

# Proxy Cloud.gov pages content at the root of the application
class PagesController < ApplicationController
  # We must remove this for proxy of JS assets to be loaded by the browser
  protect_from_forgery except: :assets

  # TODO: When launched, the cloud.gov pages need to move off the www.challenge.gov domain
  DOMAIN = Rails.configuration.static_site_interop.fetch(:domain)
  HOST = Rails.configuration.static_site_interop.fetch(:host)
  BASE_URL = Rails.configuration.static_site_interop.fetch(:base_url)

  def index
    path = "#{HOST}#{BASE_URL}/#{params[:path]}/"
    response = Faraday.get(path)
    if response.status == 404
      redirect_to "/"
    else
      body = rewrite_links(response.body)
      render body:, content_type: response.headers["Content-Type"], status: response.status
    end
  end

  def assets
    if params[:ext] == "min"
      handle_minified_asset
    else
      handle_asset
    end
  end

  def root
    path = "#{HOST}#{BASE_URL}/"
    response = Faraday.get(path)
    body = render_flash_message(
      rewrite_links(
        response.body
      )
    )
    render body:, content_type: response.headers["Content-Type"], status: response.status
  end

  private

  def handle_minified_asset
    path = "#{HOST}#{BASE_URL}/assets/#{params[:path]}.#{params[:ext]}.js"
    response = Faraday.get(path)
    send_data(response.body, type: 'application/javascript')
  end

  def handle_asset
    path = "#{HOST}#{BASE_URL}/assets/#{params[:path]}.#{params[:ext]}"
    response = Faraday.get(path)
    render body: response.body, content_type: response.headers["Content-Type"], status: response.status
  end

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

  def render_flash_message(html)
    main_index = html.index('<main id="main-content">')
    return html if flash.empty? || main_index.nil?

    flash_message = render_to_string(partial: "shared/flash")
    html.insert(main_index, flash_message)
  end
end
