require "rails_helper"

RSpec.describe "PagesController" do
  context "#root" do
    it "renders successfully" do
      stub_request(:get, "#{PagesController::HOST}#{PagesController::BASE_URL}/").
        to_return(status: 200, body: "", headers: {})

      get "/"
      expect(response).to be_ok
    end

    it "converts full paths in the response body with local paths so they proxy too" do
      body = "BEGIN_#{PagesController::HOST}#{PagesController::BASE_URL}_END"
      stub_request(:get, "#{PagesController::HOST}#{PagesController::BASE_URL}/").
        to_return(status: 200, body:, headers: {})

      get "/"
      expected_body = if PagesController::BASE_URL == "/"
        "BEGIN_//_END"
      else
        "BEGIN_/_END"
      end
      expect(response.body).to eq(expected_body)
    end
  end

  context "#assets" do
    it "works for minified js assets" do
      stub_request(:get, "#{PagesController::HOST}#{PagesController::BASE_URL}/assets/uswds.min.js").
        to_return(status: 200, body: "", headers: {})

      get "/assets/uswds.min.js"
      expect(response).to be_ok
    end

    it "works for image assets" do
      stub_request(:get, "#{PagesController::HOST}#{PagesController::BASE_URL}/assets/logo.svg").
        to_return(status: 200, body: "", headers: {})

      get "/assets/logo.svg"
      expect(response).to be_ok
    end
  end

  it "404 redirects to the root path" do
    stub_request(:get, "#{PagesController::HOST}#{PagesController::BASE_URL}/not_found/").
      to_return(status: 404, body: "", headers: {})

    get "/not_found"
    expect(response).to redirect_to("/")
  end
end
