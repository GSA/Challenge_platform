# frozen_string_literal: true

class Dev::AccountsController < ApplicationController
  skip_before_action :check_session_expiration

  def index; end

  # not mounted in production
  # only used in dev, test envs
  def login
    email = params[:email]
    @current_user = User.find_by(email:)
    renew_session
    session[:userinfo] = [{ "email" => email, "sub" => @current_user.token }]
    redirect_to dashboard_path
  end
end
