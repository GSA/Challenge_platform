RSpec.shared_examples "a page with dashboard content for a challenge manager" do
  it "has the right subtitles for a challenge manager" do
    expect(response.body).to include("Create and manage evaluation forms.")
    expect(response.body).to include("Manage submissions, evaluations, and evaluators")
    expect(response.body).to include("Learn how to make the most of the platform.")
    expect(response.body).to include("Get support on the Challenge.Gov platform.")
  end
end
