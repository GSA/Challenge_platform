# frozen_string_literal: true

# The base class for most controllers.
# Manages authenticated user sessions and other auth methods.
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

  # Authorizes the current_user if they have one of the roles or if they are an admin.
  # Suitable for use in before_action.
  #
  # * CAUTION: caller is responsible for ensuring all roles have access
  #            to all authorized controller routes.
  # * NOTE: method redirects on auth failure.
  def authorize_user(*roles)
    return if roles.include?(current_user&.role) || %w[super_admin admin].include?(current_user&.role)

    redirect_to_landing_page(alert: I18n.t("access_denied"))
  end

  # All evaluators must be active to pass this authorization
  def authorize_active_evaluators
    return unless current_user.role == 'evaluator' && current_user.status != 'active'

    redirect_to "/", alert: I18n.t("evaluator_pending_approval")
  end

  def check_gov_access
    return unless current_user.non_gov_restricted?

    redirect_to_landing_page(alert: I18n.t("access_denied"))
  end

  def redirect_admins_to_phoenix
    return unless %w[super_admin admin].include?(current_user&.role)

    redirect_to Rails.configuration.phx_interop[:phx_uri], allow_other_host: true
  end

  def redirect_solvers_to_phoenix
    return unless current_user&.role == 'solver'

    redirect_to Rails.configuration.phx_interop[:phx_uri], allow_other_host: true
  end

  def redirect_to_landing_page(options = {})
    case @current_user&.role
    when "evaluator"
      redirect_to evaluations_path, options
    when "challenge_manager"
      redirect_to phases_path, options
    else
      redirect_to "/", options
    end
  end

  def sign_in(login_userinfo)
    user = User.user_from_userinfo(login_userinfo)
    update_ial_level(user, login_userinfo[0]["ial"])

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
      redirect_to "/", alert: I18n.t("session_expired_alert")
    else
      renew_session
    end
  end

  def update_ial_level(user, ial_value)
    return unless ial_value&.end_with?("verified-facial-match-required")

    user.update(ial_level: 2)
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
      domain: Rails.configuration.app_domain,
      same_site: :lax,
      secure: Rails.env.production?,
      httponly: true
    }
  end
  # :nocov:

  def delete_phoenix_session_cookie
    cookies.delete(:_challenge_gov_key, domain: Rails.configuration.app_domain,
                                        secure: Rails.env.production?)
  end
end
