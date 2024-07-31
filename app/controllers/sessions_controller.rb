# frozen_string_literal: true

class SessionsController < ApplicationController
  before_action :check_error_result, :require_code_param, :exchange_token, only: [:result]

  def new
    # TODO: handle redirect to login page due to inactivity
  end

  def create
    login_gov = LoginGov.new
    redirect_to(login_gov.authorization_url, allow_other_host: true)
  end

  def delete
    login_gov = LoginGov.new
    # TODO: update user session status, clear out JWT
    # TODO: add session duration to the security log
    # TODO: delete session locally and Phoenix
    redirect_to(login_gov.logout_url)
  end

  def result
    # TODO: store the user_info in the session
    # session[:user_info] = @login_userinfo
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
end