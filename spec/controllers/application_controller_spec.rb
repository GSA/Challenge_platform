require 'rails_helper'

RSpec.describe ApplicationController do
  it 'instantiates the controller' do
    expect(described_class.new).to be_a(described_class)
  end
end
