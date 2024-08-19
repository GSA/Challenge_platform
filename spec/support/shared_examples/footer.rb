RSpec.shared_examples "a page with footer content" do
  it "has a footer with the expected links" do
    expect(response.body).to include("About")
    expect(response.body).to include("Contact")
    expect(response.body).to include("Terms of use")
    expect(response.body).to include("Privacy Policy")
    expect(response.body).to include("Innovator Resources")
    expect(response.body).to include("Agency Resources")
    expect(response.body).to include("Archived Challenges")
    expect(response.body).to include("Active Challenges")
    expect(response.body).to include("GSA Privacy Policy")
    expect(response.body).to include("Accessibility")
    expect(response.body).to include("FOIA")
    expect(response.body).to include("USA.gov")
  end

  it "has a footer with a Contact Us email link" do
    expect(response.body).to include("team@challenge.gov")
    expect(response.body).to include('href="mailto:team@challenge.gov"')
  end

  it "has a footer with the expected social media icons" do
    expect(response.body).to include('alt="Twitter"')
    expect(response.body).to include('alt="Facebook"')
    expect(response.body).to include('alt="YouTube"')
    expect(response.body).to include('alt="LinkedIn"')
    expect(response.body).to include('alt="Github"')
  end
end
