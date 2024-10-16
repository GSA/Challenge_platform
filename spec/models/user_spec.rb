# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id                         :bigint           not null, primary key
#  email                      :string(255)      not null
#  password_hash              :string(255)
#  token                      :uuid
#  first_name                 :string(255)
#  last_name                  :string(255)
#  phone_number               :string(255)
#  inserted_at                :datetime         not null
#  updated_at                 :datetime         not null
#  email_verification_token   :string(255)
#  email_verified_at          :datetime
#  role                       :string(255)      default("user"), not null
#  password_reset_token       :uuid
#  password_reset_expires_at  :datetime
#  finalized                  :boolean          default(TRUE), not null
#  avatar_key                 :uuid
#  avatar_extension           :string(255)
#  display                    :boolean          default(TRUE), not null
#  terms_of_use               :datetime
#  privacy_guidelines         :datetime
#  agency_id                  :bigint
#  last_active                :datetime
#  status                     :string(255)
#  active_session             :boolean          default(FALSE)
#  renewal_request            :string(255)
#  jwt_token                  :text
#  recertification_expired_at :datetime
#
require 'rails_helper'

RSpec.describe User do
  let(:gov_userinfo) do
    [{
      "email" => "test@example.gov",
      "sub" => SecureRandom.uuid,
      "role" => "challenge_manager"
    }]
  end

  let(:mil_userinfo) do
    [{
      "email" => "test@example.mil",
      "sub" => SecureRandom.uuid,
      "role" => "challenge_manager"
    }]
  end

  let(:non_gov_userinfo) do
    [{
      "email" => "test@example.com",
      "sub" => SecureRandom.uuid,
      "role" => "challenge_manager"
    }]
  end

  describe 'validations' do
    it_behaves_like 'a model with required attributes', [:email]

    it "is valid with a valid role" do
      User::ROLES.each do |role|
        user = User.new(email: "test@example.com", role:)
        expect(user).to be_valid
      end
    end

    it "is invalid with an invalid role" do
      user = described_class.new(email: "test@example.com", role: "invalid_role")
      expect(user).not_to be_valid
      expect(user.errors[:role]).to include("is not included in the list")
    end
  end

  describe 'default values' do
    it 'sets active_session to false by default' do
      user = described_class.new
      expect(user.active_session).to be_falsey
    end
  end

  describe 'timestamps' do
    it 'properly sets inserted_at and updated_at' do
      email = gov_userinfo[0]["email"]
      token = gov_userinfo[0]["sub"]
      role = gov_userinfo[0]["role"]

      user = described_class.create!(email:, token:, role:)

      expect(user.inserted_at).not_to be_nil
      expect(user.updated_at).not_to be_nil

      expect(user.inserted_at).to be_within(1.second).of(Time.current)
      expect(user.updated_at).to be_within(1.second).of(Time.current)

      original_inserted_at = user.inserted_at
      original_updated_at = user.updated_at

      travel_to 1.hour.from_now do
        user.update!(email: 'new-email@example.com')

        expect(user.inserted_at).to eq(original_inserted_at)
        expect(user.updated_at).to be > original_updated_at
        expect(user.updated_at).to be_within(1.second).of(Time.current)
      end
    end
  end

  describe 'user_from_userinfo' do
    it 'finds user if one matches token' do
      email = gov_userinfo[0]["email"]
      token = gov_userinfo[0]["sub"]
      role = gov_userinfo[0]["role"]

      user = described_class.create!(email:, token:, role:)

      found_user = described_class.user_from_userinfo(gov_userinfo)

      expect(user).to eq(found_user)
    end

    it 'creates pending challenge_manager user if no matching token or email and .gov email' do
      email = gov_userinfo[0]["email"]
      token = gov_userinfo[0]["sub"]

      created_user = described_class.user_from_userinfo(gov_userinfo)

      expect(created_user.email).to eq(email)
      expect(created_user.token).to eq(token)
      expect(created_user.role).to eq("challenge_manager")
      expect(created_user.status).to eq("pending")
    end

    it 'creates pending challenge_manager user if no matching token or email and .mil email' do
      email = mil_userinfo[0]["email"]
      token = mil_userinfo[0]["sub"]

      created_user = described_class.user_from_userinfo(mil_userinfo)

      expect(created_user.email).to eq(email)
      expect(created_user.token).to eq(token)
      expect(created_user.role).to eq("challenge_manager")
      expect(created_user.status).to eq("pending")
    end

    it 'creates active solver user if no matching token or email and non .gov email' do
      email = non_gov_userinfo[0]["email"]
      token = non_gov_userinfo[0]["sub"]

      created_user = described_class.user_from_userinfo(non_gov_userinfo)

      expect(created_user.email).to eq(email)
      expect(created_user.token).to eq(token)
      expect(created_user.role).to eq("solver")
      expect(created_user.status).to eq("active")
    end

    it 'update user with token if matching email but no token set (from admin creation)' do
      email = gov_userinfo[0]["email"]
      token = gov_userinfo[0]["sub"]
      role = gov_userinfo[0]["role"]

      user = described_class.create!(email:, role:)
      expect(user.token).to be_nil

      updated_user = described_class.user_from_userinfo(gov_userinfo)

      expect(updated_user.id).to eq(user.id)
      expect(updated_user.email).to eq(email)
      expect(updated_user.token).to eq(token)
    end
  end
end
