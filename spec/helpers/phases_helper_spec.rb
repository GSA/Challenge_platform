require 'rails_helper'

describe PhasesHelper do
  describe "#phase_number" do
    it "gives 1 for the first phase by start_date" do
      c = create_challenge
      p2 = create_phase(challenge_id: c.id, start_date: 1.month.from_now, end_date: 6.weeks.from_now)
      p1 = create_phase(challenge_id: c.id, start_date: 1.week.from_now, end_date: 2.weeks.from_now)
      expect(helper.phase_number(p1)).to eq(1)
      expect(helper.phase_number(p2)).to eq(2)
    end
  end
end
