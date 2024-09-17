require "rails_helper"

RSpec.describe "SessionsController" do
  it "get new renders successfully" do
    get "/session/new"
    expect(response).to render_template(:new)
  end

  it "post create redirects to login.gov" do
    auth_host, _auth_query = LoginGov.new.authorization_url.split("?")
    post "/session"
    expect(response).to redirect_to(/\A#{auth_host}/)
  end

  it "delete session logs the user out" do
    delete "/session"
    assert_response :redirect
  end

  it "get /auth/result without params redirects to login" do
    get "/auth/result"
    expect(response).to redirect_to("/session/new")
    expect(flash[:error]).to include("Please try again.")
  end

  it "get /auth/result with error param redirects to login" do
    get "/auth/result", params: { error: "there was an error" }
    expect(response).to redirect_to("/session/new")
    expect(flash[:error]).to include("Please try again.")
  end

  it "get /auth/result successful" do
    code = "ABC123"
    login_gov = instance_double(LoginGov)
    allow(LoginGov).to receive(:new).and_return(login_gov)
    allow(login_gov).to receive(:exchange_token_from_auth_result).with(code).and_return(
      [{ email: "test@example.com", sub: "sub" }]
    )

    # rubocop:disable RSpec/AnyInstance
    allow_any_instance_of(SessionsController).to(
      receive(:send_user_jwt_to_phoenix).with(instance_of(String)).and_return(true)
    )
    # rubocop:enable RSpec/AnyInstance

    get "/auth/result", params: { code: }
    expect(response).to have_http_status(:redirect)
    expect(response).to redirect_to("/dashboard")
  end

  it "times out the session" do
    session_timeout_in_minutes = SessionsController::SESSION_TIMEOUT_IN_MINUTES

    email = "test@example.gov"
    token = SecureRandom.uuid

    User.create!({ email:, token: })

    code = "ABC123"
    login_gov = instance_double(LoginGov)
    allow(LoginGov).to receive(:new).and_return(login_gov)
    allow(login_gov).to receive(:exchange_token_from_auth_result).with(code).and_return(
      [{ email:, sub: token }]
    )

    # rubocop:disable RSpec/AnyInstance
    allow_any_instance_of(SessionsController).to(
      receive(:send_user_jwt_to_phoenix).with(instance_of(String)).and_return(true)
    )
    # rubocop:enable RSpec/AnyInstance

    get "/auth/result", params: { code: }

    expect(session[:userinfo]).not_to be_nil
    expect(session[:session_timeout_at]).not_to be_nil

    travel_to (session_timeout_in_minutes.to_i + 1).minutes.from_now do
      get dashboard_path

      expect(session[:userinfo]).to be_nil
      expect(session[:session_timeout_at]).to be_nil
    end
  end
end
