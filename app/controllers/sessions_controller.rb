class SessionsController < ApplicationController

  before_action :handle_result_error, :well_known_configuration, :decode_token, only: [:result]

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
    
  end

  private

  def handle_result_error
    if params[:error]
      Rails.logger.error("Login.gov authentication error: #{params[:error]}")
      flash[:error] = "There was an issue with logging in. Please try again."
      redirect_to new_session_path
    end

    if params[:code].nil? && params[:state].nil?
      Rails.logger.error("Login.gov unknown error")
      flash[:error] = "Please try again."
      redirect_to new_session_path
    end
  end

  def well_known_configuration
    @login_gov = LoginGov.new
    status, body = @login_gov.get_well_known_configuration

    if status != 200
      Rails.logger.error("well-known/openid-configuration error: code=#{status} - body:\n#{body}")
      flash[:error] = "There was an issue logging in."
      redirect_to new_session_path
      return
    end

    Rails.logger.debug("well_known_config response body=#{body}")
    @openid_config = body
  end

  def decode_token
    private_key = @login_gov.private_key
  end
end
