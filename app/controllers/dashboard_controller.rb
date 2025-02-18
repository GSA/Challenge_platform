# frozen_string_literal: true

# The dashboard controller serves the logged-in homepage of the app.
class DashboardController < ApplicationController
  def index
    redirect_to "/"
  end
end
