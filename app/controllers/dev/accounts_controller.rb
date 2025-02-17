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
      case @current_user.role
      when "evaluator"
        redirect_to evaluations_path
      else
        redirect_to phases_path
      end
    end
  end
end
