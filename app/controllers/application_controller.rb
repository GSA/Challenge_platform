# frozen_string_literal: true

class ApplicationController < ActionController::Base
  helper_method :current_user, :logged_in?

  def current_user
    if session[:userinfo]
      user_token = session["userinfo"][0]["sub"]
      @current_user ||= User.find_by(token: user_token) if user_token
    end
  end

  def logged_in?
    !!current_user
  end

  def sign_in(login_userinfo)
    user = User.user_from_userinfo(login_userinfo)

    @current_user = user
    session[:userinfo] = login_userinfo
  end

  def sign_out
    @current_user = nil
    session.delete(:userinfo)
  end

  def redirect_if_logged_in(path = "/dashboard")
    if logged_in?
      redirect_to path, notice: "You are already logged in."
    end
  end
end
