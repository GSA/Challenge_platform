# frozen_string_literal: true

class ApplicationController < ActionController::Base
  helper_method :current_user, :logged_in?

  before_action :check_session_expiration

  def current_user
    return unless session[:userinfo]

    user_token = session["userinfo"][0]["sub"]
    @current_user ||= User.find_by(token: user_token) if user_token
  end

  def logged_in?
    !!current_user
  end

  def sign_in(login_userinfo)
    user = User.user_from_userinfo(login_userinfo)

    @current_user = user
    renew_session
    session[:userinfo] = login_userinfo
  end

  def sign_out
    @current_user = nil
    session.delete(:userinfo)
    session.delete(:session_timeout_at)
  end

  def renew_session
    session[:session_timeout_at] = Time.current + ENV.fetch("SESSION_TIMEOUT_IN_MINUTES", 15).to_i.seconds
  end

  def check_session_expiration
    if session[:session_timeout_at].present? && session[:session_timeout_at] < Time.current
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
end
