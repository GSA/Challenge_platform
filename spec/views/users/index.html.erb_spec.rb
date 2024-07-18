require 'rails_helper'

RSpec.describe "users/index", type: :view do
  before(:each) do
    assign(:users, [
      User.create!(
        role: "Role",
        status: "Status",
        finalized: false,
        display: false,
        email: "Email",
        email_confirmation: "Email Confirmation",
        password_hash: "Password Hash",
        password: "Password",
        password_confirmation: "Password Confirmation",
        token: "",
        jwt_token: "Jwt Token",
        email_verification_token: "Email Verification Token",
        password_reset_token: "",
        first_name: "First Name",
        last_name: "Last Name",
        phone_number: "Phone Number",
        avatar_key: "",
        avatar_extension: "Avatar Extension",
        agency_id: 2,
        active_session: false,
        renewal_request: "Renewal Request"
      ),
      User.create!(
        role: "Role",
        status: "Status",
        finalized: false,
        display: false,
        email: "Email",
        email_confirmation: "Email Confirmation",
        password_hash: "Password Hash",
        password: "Password",
        password_confirmation: "Password Confirmation",
        token: "",
        jwt_token: "Jwt Token",
        email_verification_token: "Email Verification Token",
        password_reset_token: "",
        first_name: "First Name",
        last_name: "Last Name",
        phone_number: "Phone Number",
        avatar_key: "",
        avatar_extension: "Avatar Extension",
        agency_id: 2,
        active_session: false,
        renewal_request: "Renewal Request"
      )
    ])
  end

  it "renders a list of users" do
    render
    cell_selector = Rails::VERSION::STRING >= '7' ? 'div>p' : 'tr>td'
    assert_select cell_selector, text: Regexp.new("Role".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("Status".to_s), count: 2
    assert_select cell_selector, text: Regexp.new(false.to_s), count: 2
    assert_select cell_selector, text: Regexp.new(false.to_s), count: 2
    assert_select cell_selector, text: Regexp.new("Email".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("Email Confirmation".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("Password Hash".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("Password".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("Password Confirmation".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("Jwt Token".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("Email Verification Token".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("First Name".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("Last Name".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("Phone Number".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("Avatar Extension".to_s), count: 2
    assert_select cell_selector, text: Regexp.new(2.to_s), count: 2
    assert_select cell_selector, text: Regexp.new(false.to_s), count: 2
    assert_select cell_selector, text: Regexp.new("Renewal Request".to_s), count: 2
  end
end
