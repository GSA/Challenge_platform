RSpec.shared_examples "a page with dashboard content for a challenge manager" do
  it "has the right subtitles for a challenge manager" do
    expect(response.body).to include("Create and manage evaluation forms.")
    expect(response.body).to include("Manage submissions, evaluations, and evaluators")
    expect(response.body).to include("Learn how to make the most of the platform.")
    expect(response.body).to include("Get support on the Challenge.Gov platform.")
  end
end

RSpec.shared_examples "a page with dashboard content for an evaluator" do
  it "has the right subtitles for an evaluator" do
    expect(response.body).to include("Evaluate my assigned submissions.")
    expect(response.body).to include("Learn how to make the most of the platform.")
    expect(response.body).to include("Get support on the Challenge.Gov platform.")
  end
end
