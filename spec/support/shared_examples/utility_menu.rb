RSpec.shared_examples "a page with utility menu links for all users" do
  it "has links shared across all user roles" do
    expect(response.body).to include("Dashboard")
    expect(response.body).to include("Submissions")
    expect(response.body).to include("Resources")
  end
end

RSpec.shared_examples "a page with utility menu links for a challenge manager" do
  it "has the right links for a challenge manager" do
    expect(response.body).to include("Challenges")
    expect(response.body).to include("Evaluation Forms")
  end
end
