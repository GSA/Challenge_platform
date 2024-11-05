# frozen_string_literal: true

module ManageSubmissionsHelper
    def eligible_for_evaluation?(submission)
      submission.judging_status.in? ["qualified", "selected", "winner"]
    end 

    def selected_to_advance?(submission)
      submission.judging_status.in? ["selected", "winner"]
    end   
end
