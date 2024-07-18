require 'rails_helper'

RSpec.describe "users/new", type: :view do
  before(:each) do
    assign(:user, User.new(
      role: "MyString",
      status: "MyString",
      finalized: false,
      display: false,
      email: "MyString",
      email_confirmation: "MyString",
      password_hash: "MyString",
      password: "MyString",
      password_confirmation: "MyString",
      token: "",
      jwt_token: "MyString",
      email_verification_token: "MyString",
      password_reset_token: "",
      first_name: "MyString",
      last_name: "MyString",
      phone_number: "MyString",
      avatar_key: "",
      avatar_extension: "MyString",
      agency_id: 1,
      active_session: false,
      renewal_request: "MyString"
    ))
  end

  it "renders new user form" do
    render

    assert_select "form[action=?][method=?]", users_path, "post" do

      assert_select "input[name=?]", "user[role]"

      assert_select "input[name=?]", "user[status]"

      assert_select "input[name=?]", "user[finalized]"

      assert_select "input[name=?]", "user[display]"

      assert_select "input[name=?]", "user[email]"

      assert_select "input[name=?]", "user[email_confirmation]"

      assert_select "input[name=?]", "user[password_hash]"

      assert_select "input[name=?]", "user[password]"

      assert_select "input[name=?]", "user[password_confirmation]"

      assert_select "input[name=?]", "user[token]"

      assert_select "input[name=?]", "user[jwt_token]"

      assert_select "input[name=?]", "user[email_verification_token]"

      assert_select "input[name=?]", "user[password_reset_token]"

      assert_select "input[name=?]", "user[first_name]"

      assert_select "input[name=?]", "user[last_name]"

      assert_select "input[name=?]", "user[phone_number]"

      assert_select "input[name=?]", "user[avatar_key]"

      assert_select "input[name=?]", "user[avatar_extension]"

      assert_select "input[name=?]", "user[agency_id]"

      assert_select "input[name=?]", "user[active_session]"

      assert_select "input[name=?]", "user[renewal_request]"
    end
  end
end
