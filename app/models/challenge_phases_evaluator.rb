# frozen_string_literal: true

# == Schema Information
#
# Table name: challenge_phases_evaluators
#
#  id           :bigint           not null, primary key
#  challenge_id :bigint           not null
#  phase_id     :bigint           not null
#  user_id      :bigint           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
class ChallengePhasesEvaluator < ApplicationRecord
  belongs_to :challenge
  belongs_to :phase
  belongs_to :user
end
