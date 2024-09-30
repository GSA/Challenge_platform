# frozen_string_literal: true

# == Schema Information
#
# Table name: challenge_managers
#
#  id           :bigint           not null, primary key
#  challenge_id :bigint
#  user_id      :bigint
#  revoked_at   :datetime
#

class ChallengeManager < ApplicationRecord
  belongs_to :challenge
  belongs_to :user
end
