RSpec.shared_examples "a page with header content" do
  it "has a header with the expected links" do
    expect(response.body).to include("Find a Challenge")
    expect(response.body).to include("Resources")
    expect(response.body).to include("Events")
    expect(response.body).to include("Contact")
  end
end
  