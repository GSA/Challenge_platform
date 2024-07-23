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
    skip "not implemented"
    delete "/session/:id"
    assert_response :success
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
    allow(login_gov).to receive(:exchange_token_from_auth_result).with(code).and_return({ email: "test@example.com" })
    get "/auth/result", params: { code: }
  end
end
