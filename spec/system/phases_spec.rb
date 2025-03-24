# frozen_string_literal: true

require 'rails_helper'

describe "A11y", :js do
  describe "Logged-in as a Challenge Manager" do
    let(:user) { create_user(role: "challenge_manager") }

    before do
      system_login_user(user)
    end

    context "with a gov email" do
      before do
        user.update(email: generate_user_email(type: :gov))
      end

      it "manage phases index page is accessible with no challenges" do
        visit phases_path
        expect(user.role).to eq("challenge_manager")
        expect(page).to(be_axe_clean)
      end

      context "with challenges" do
        let!(:challenge) { create_challenge(user: user, title: "Boston Tea Party Cleanup") }
        let!(:phase) { create_phase(challenge_id: challenge.id) }

        it "manage phases index page is accessible with one challenge" do
          visit phases_path
          expect(user.role).to eq("challenge_manager")
          expect(page).to have_content("Boston Tea Party Cleanup")
          expect(page).to(be_axe_clean)
        end

        it "renders the create new challenge button" do
          visit phases_path

          expect(page).to have_button("Create New Challenge")
        end

        it "does not show the identity verification banner" do
          visit phases_path

          expect(page).to have_no_css(".usa-alert--info",
                                      text: "To view submission information on Challenge.gov, you must verify your identity with Login.gov")
        end

        it "displays none yet text under submissions when no submissions" do
          visit phases_path

          expect(page).to have_css('td[data-label="# of Submissions"]', text: "None yet")
        end

        it "displays submissions count link when submissions exist" do
          create(:submission, challenge:, phase:)

          visit phases_path

          expect(page).to have_css('td[data-label="# of Submissions"]', text: "1 submissions")
          expect(page).to have_link("1 submissions", href: submissions_phase_path(phase))
        end

        it "displays evaluator invite link under evaluators when no evaluators" do
          visit phases_path

          expect(page).to have_css('td[data-label="# of Evaluators"]', text: "Invite evaluators")
          expect(page).to have_link("Invite evaluators", href: phase_evaluators_path(phase))
        end

        it "displays evaluators count text instead of link when evaluators exist" do
          evaluator = create(:user, :evaluator)
          create(:challenge_phases_evaluator, user: evaluator, challenge:, phase:)

          visit phases_path

          expect(page).to have_css('td[data-label="# of Evaluators"]', text: "1 evaluators")
          expect(page).to have_link("1 evaluators", href: phase_evaluators_path(phase))
        end
      end
    end

    context "with a non gov email" do
      let!(:challenge) { create_challenge(user: user, title: "Boston Tea Party Cleanup") }
      let!(:phase) { create_phase(challenge_id: challenge.id) }

      before do
        user.update(email: generate_user_email(type: :non_gov))
      end

      it "does not render the create new challenge button" do
        visit phases_path

        expect(page).to have_no_button("Create New Challenge")
      end

      it "shows the identity verification banner if not ial_level 2" do
        visit phases_path

        expect(page).to have_css(".usa-alert--info",
                                 text: "To view submission information on Challenge.gov, you must verify your identity with Login.gov")
      end

      it "does not show the identity verification banner if ial_level 2" do
        user.update(ial_level: 2)
        visit phases_path

        expect(page).to have_no_css(".usa-alert--info",
                                    text: "To view submission information on Challenge.gov, you must verify your identity with Login.gov")
      end

      it "displays none yet text under submissions when no submissions" do
        visit phases_path

        expect(page).to have_css('td[data-label="# of Submissions"]', text: "None yet")
      end

      it "displays submissions count text instead of link when submissions exist" do
        create(:submission, challenge:, phase:)

        visit phases_path

        expect(page).to have_css('td[data-label="# of Submissions"]', text: "1 submissions")
        expect(page).to have_no_link("1 Submissions")
      end

      it "displays none yet text under evaluators when no evaluators" do
        visit phases_path

        expect(page).to have_css('td[data-label="# of Evaluators"]', text: "None Yet")
        expect(page).to have_no_link("Invite Evaluators")
      end

      it "displays evaluators count text instead of link when evaluators exist" do
        evaluator = create(:user, :evaluator)
        create(:challenge_phases_evaluator, user: evaluator, challenge:, phase:)

        visit phases_path

        expect(page).to have_css('td[data-label="# of Evaluators"]', text: "1 evaluators")
        expect(page).to have_no_link("1 evaluators")
      end
    end
  end
end
