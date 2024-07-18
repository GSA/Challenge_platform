require 'rails_helper'

RSpec.describe "users/show", type: :view do
  before(:each) do
    assign(:user, User.create!(
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
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Role/)
    expect(rendered).to match(/Status/)
    expect(rendered).to match(/false/)
    expect(rendered).to match(/false/)
    expect(rendered).to match(/Email/)
    expect(rendered).to match(/Email Confirmation/)
    expect(rendered).to match(/Password Hash/)
    expect(rendered).to match(/Password/)
    expect(rendered).to match(/Password Confirmation/)
    expect(rendered).to match(//)
    expect(rendered).to match(/Jwt Token/)
    expect(rendered).to match(/Email Verification Token/)
    expect(rendered).to match(//)
    expect(rendered).to match(/First Name/)
    expect(rendered).to match(/Last Name/)
    expect(rendered).to match(/Phone Number/)
    expect(rendered).to match(//)
    expect(rendered).to match(/Avatar Extension/)
    expect(rendered).to match(/2/)
    expect(rendered).to match(/false/)
    expect(rendered).to match(/Renewal Request/)
  end
end
