require 'rails_helper'

RSpec.describe Member, type: :model do
  it "has a valid factory" do
    expect(create(:member)).to be_valid
  end

  describe "#full_name" do
   subject { create(:member)}
   it "returns the full name" do
    expect(subject.full_name).to eq(subject.first_name+" "+subject.last_name)
   end
  end
end
