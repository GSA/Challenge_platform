class SessionsController < ApplicationController

  before_action :check_result_error, :exchange_token, only: [:result]

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

  def check_result_error
    if params[:error]
      Rails.logger.error("Login.gov authentication error: #{params[:error]}")
      flash[:error] = "There was an issue with logging in. Please try again."
      redirect_to new_session_path
    end

    if params[:code].nil?
      Rails.logger.error("Login.gov unknown error")
      flash[:error] = "Please try again."
      redirect_to new_session_path
    end
  end

  # Authenticates a user with login.gov using JWT
  def exchange_token
    login_gov = LoginGov.new
    @login_userinfo = login_gov.exchange_token_from_auth_result params[:code]
    Rails.logger.debug("GOT userinfo=#{@login_userinfo}")
  rescue LoginGov::LoginApiError => error
    Rails.logger.error("LoginGov::LoginApiError(#{error.message}) status_code(#{error.status_code}) response_body:\n#{error.response_body}")
    flash[:error] = "There was an issue logging in."
    redirect_to new_session_path
  end
end
