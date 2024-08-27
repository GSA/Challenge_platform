RSpec.shared_examples "a page with utility menu links for a public solver" do
    it "has the right links" do
        expect(response.body).to include("Dashboard")
        expect(response.body).to include("Submissions")
        expect(response.body).to include("User Guides")
        expect(response.body).to include("Help")
    end
end

RSpec.shared_examples "a page with utility menu links for a challenge manager" do
    it "has the right links" do
        expect(response.body).to include("Dashboard")
        expect(response.body).to include("Challenges")
        expect(response.body).to include("Submissions")
        expect(response.body).to include("Evaluations")
        expect(response.body).to include("User Guides")
        expect(response.body).to include("Help")
    end
end   

RSpec.shared_examples "a page with utility menu links for an evaluator" do
    it "has the right links" do
        expect(response.body).to include("Dashboard")
        expect(response.body).to include("Evaluations")
        expect(response.body).to include("User Guides")
        expect(response.body).to include("Help")
    end
end

  