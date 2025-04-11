# frozen_string_literal: true

# SessionsConroller manages session requests: login, logout and timeout functions.
# This controller receives the redirect from login.gov and stores the valid user session.
class SessionsController < ApplicationController
  before_action :check_error_result, :require_code_param, :exchange_token, only: [:result]
  skip_before_action :check_session_expiration, only: [:timeout, :destroy]

  SESSION_TIMEOUT_IN_MINUTES = 15

  def new
    # TODO: handle redirect to login page due to inactivity
  end

  def create
    login_gov = LoginGov.new
    redirect_to(login_gov.authorization_url, allow_other_host: true)
  end

  def destroy
    login_gov = LoginGov.new
    # TODO: add session duration to the security log
    sign_out
    redirect_to(login_gov.logout_url, allow_other_host: true)
  end

  def result
    sign_in(@login_userinfo)
    redirect_to_landing_page
  end

  def renew
    renew_session
    head(:ok)
  end

  def timeout
    sign_out
    flash[:alert] = I18n.t("session_expired_alert")
    head(:ok)
  end

  def failure_to_proof; end

  def external_login
    return head(:unauthorized) unless request.headers["Login-Secret"] == ENV["LOGIN_SECRET"]

    user_jwt = request.headers["User-JWT"]
    decoded = decode_user_jwt(user_jwt)

    if decoded
      session[:userinfo] = decoded
      session[:session_timeout_at] = Time.zone.now + SESSION_TIMEOUT_IN_SECONDS
      # Ensure this returns a Set-Cookie resp_header to Phoenix
      head(:ok)
    else
      head(:unauthorized)
    end
  end

  def external_renew
    return head(:unauthorized) unless request.headers["Login-Secret"] == ENV["LOGIN_SECRET"]

    if session[:userinfo].present?
      session[:session_timeout_at] = Time.zone.now + SESSION_TIMEOUT_IN_SECONDS
      # Ensure this returns a Set-Cookie resp_header to Phoenix
      head(:ok)
    else
      head(:unauthorized)
    end
  end

  private

  def check_error_result
    return unless params[:error]

    Rails.logger.error("Login.gov authentication error: #{params[:error]}")
    flash[:error] = t("login_error")
    redirect_to new_session_path
  end

  def require_code_param
    return if params[:code].present?

    Rails.logger.error("Login.gov unknown error")
    flash[:error] = t("please_try_again")
    redirect_to new_session_path
  end

  # Authenticates a user with login.gov using JWT
  def exchange_token
    login_gov = LoginGov.new
    @login_userinfo = login_gov.exchange_token_from_auth_result(params[:code])
    Rails.logger.debug do
      "userinfo=#{@login_userinfo}"
    end
  rescue LoginGov::LoginApiError => e
    Rails.logger.error("LoginGov::LoginApiError(#{e.message}) status(#{e.status_code}):\n#{e.response_body}")
    flash[:error] = t("login_error")
    redirect_to new_session_path
  end

  def decode_user_jwt(_user_jwt)
    # Decode the JWT from Phoenix containing user_info, etc
  rescue JWT::DecodeError => e
    Rails.logger.error("JWT decode failed: #{e}")
    nil
  end
end
