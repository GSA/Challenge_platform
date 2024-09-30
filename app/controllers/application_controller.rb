# frozen_string_literal: true

class ApplicationController < ActionController::Base
  helper_method :current_user, :logged_in?

  before_action :check_session_expiration, except: [:sign_out]
  before_action :redirect_admins_to_phoenix
  before_action :redirect_solvers_to_phoenix

  def current_user
    return unless session[:userinfo]

    user_token = session["userinfo"][0]["sub"]
    @current_user ||= User.find_by(token: user_token) if user_token
  end

  def logged_in?
    !!current_user
  end

  def authorize_user(role)
    return if current_user&.role == role || %w[super_admin admin].include?(current_user&.role)

    redirect_to dashboard_path, alert: I18n.t("access_denied")
  end

  def redirect_admins_to_phoenix
    return unless %w[super_admin admin].include?(current_user&.role)

    redirect_to Rails.configuration.phx_interop[:phx_uri], allow_other_host: true
  end

  def redirect_solvers_to_phoenix
    return unless current_user&.role == 'solver'

    redirect_to Rails.configuration.phx_interop[:phx_uri], allow_other_host: true
  end

  def sign_in(login_userinfo)
    user = User.user_from_userinfo(login_userinfo)

    user_jwt = generate_user_jwt(user)
    send_user_jwt_to_phoenix(user_jwt)

    @current_user = user
    renew_session
    session[:userinfo] = login_userinfo
  end

  def sign_out
    @current_user = nil

    session.delete(:userinfo)
    session.delete(:session_timeout_at)

    delete_phoenix_session_cookie
  end

  def renew_session
    session[:session_timeout_at] = Time.current + SessionsController::SESSION_TIMEOUT_IN_MINUTES.minutes
  end

  def check_session_expiration
    return unless logged_in?

    if session[:session_timeout_at].blank? || session[:session_timeout_at] < Time.current
      sign_out
      redirect_to dashboard_path, alert: I18n.t("session_expired_alert")
    else
      renew_session
    end
  end

  def redirect_if_logged_in(path = "/dashboard")
    return unless logged_in?

    redirect_to path, notice: I18n.t("already_logged_in_notice")
  end

  def generate_user_jwt(user)
    payload = {
      email: user.email,
      sub: user.token,
      exp: 24.hours.from_now.to_i
    }

    JWT.encode(payload, Rails.configuration.phx_interop[:jwt_secret], 'HS256')
  end

  # :nocov:
  def send_user_jwt_to_phoenix(jwt)
    res = phoenix_external_login_request(jwt)
    phoenix_cookie = extract_phoenix_cookie_from_response(res)
    phoenix_session_cookie(phoenix_cookie)

    res.code == '200'
  rescue StandardError => e
    Rails.logger.error(e)
  end

  # rubocop:disable Metrics/AbcSize
  def phoenix_external_login_request(jwt)
    uri = URI("#{Rails.configuration.phx_interop[:phx_uri]}/api/external_login")

    req = Net::HTTP::Post.new(uri)
    req['Login-Secret'] = Rails.configuration.phx_interop[:login_secret]
    req['User-JWT'] = jwt
    req['Remote-IP'] = request.remote_ip

    Net::HTTP.start(uri.hostname, uri.port) do |http|
      http.request(req)
    end
  end
  # rubocop:enable Metrics/AbcSize

  def extract_phoenix_cookie_from_response(res)
    cookie_header = res['Set-Cookie']
    cookie_value = cookie_header.split(';').first.split('=').last

    { value: cookie_value }
  end

  def phoenix_session_cookie(phoenix_cookie)
    cookies[:_challenge_gov_key] = {
      value: phoenix_cookie[:value],
      secure: true,
      httponly: true,
      same_site: :lax
    }
  end
  # :nocov:

  def delete_phoenix_session_cookie
    cookies.delete(:_challenge_gov_key)
  end
end
