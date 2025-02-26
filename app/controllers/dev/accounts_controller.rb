# frozen_string_literal: true

module Dev
  # AccountsController offers login convenience for dev and test environments only.
  class AccountsController < ApplicationController
    skip_before_action :check_session_expiration

    def index; end

    # not mounted in production
    # only used in dev, test envs
    def login
      email = params[:email]
      @current_user = User.find_by(email:)
      renew_session
      session[:userinfo] = [{ "email" => email, "sub" => @current_user.token }]

      redirect_to_landing_page
    end
  end
end
