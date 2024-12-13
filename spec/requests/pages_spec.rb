require "rails_helper"

RSpec.describe "PagesController" do
  it "get new renders successfully" do
    stub_request(:get, PagesController::HOST + PagesController::BASE_URL).
        to_return(status: 200, body: "", headers: {})

    get "/"
    expect(response).to be_ok
  end

  it "removes full paths to assets so they proxy too" do
    stub_request(:get, PagesController::HOST + PagesController::BASE_URL).
        to_return(status: 200, body: PagesController::HOST + PagesController::BASE_URL, headers: {})

    get "/"
    expect(response.body).to eq("//")
  end

  it "works for minified js assets" do
    stub_request(:get, PagesController::HOST + PagesController::BASE_URL + "assets/uswds.min.js").
        to_return(status: 200, body: "", headers: {})

    get "/assets/uswds.min.js"
    expect(response).to be_ok
  end

  it "works for image assets" do
    stub_request(:get, PagesController::HOST + PagesController::BASE_URL + "assets/logo.svg").
        to_return(status: 200, body: "", headers: {})

    get "/assets/logo.svg"
    expect(response).to be_ok
  end

  it "404s to the dashboard" do
    stub_request(:get, PagesController::HOST + PagesController::BASE_URL + "not_found/").
        to_return(status: 404, body: "", headers: {})

    get "/not_found"
    expect(response).to redirect_to("/dashboard")
  end
end
