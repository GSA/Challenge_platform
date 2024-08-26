RSpec.shared_examples "a page with a utility menu" do
    it "has a utility menu with the expected links for a public solver" do
        expect(response.body).to include("Dashboard")
        expect(response.body).to include("Submissions")
        expect(response.body).to include("User Guides")
        expect(response.body).to include("Help")
    end

    it "has a utility menu with the expected links for a challenge manager" do
        expect(response.body).to include("Dashboard")
        expect(response.body).to include("Challenges")
        expect(response.body).to include("Submissions")
        expect(response.body).to include("Evaluations")
        expect(response.body).to include("User Guides")
        expect(response.body).to include("Help")
    end

    it "has a utility menu with the expected links for a public solver" do
        expect(response.body).to include("Dashboard")
        expect(response.body).to include("Evaluations")
        expect(response.body).to include("User Guides")
        expect(response.body).to include("Help")
    end
end
  