RSpec.shared_examples "a page with utility menu links for all users" do
  it "has links shared across all user roles" do
    expect(response.body).to have_css("#utility-menu-link-Support")
  end
end

RSpec.shared_examples "a page with utility menu links for a challenge manager" do
  it "has the right links for a challenge manager" do
    expect(response.body).to have_css("#utility-menu-link-Challenges")
  end
end

RSpec.shared_examples "a page with utility menu links for an evaluator" do
  it "has the right links for an evaluator" do
    expect(response.body).to have_css("#utility-menu-link-Evaluations")
  end
end
