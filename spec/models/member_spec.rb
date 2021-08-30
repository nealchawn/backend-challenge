require 'rails_helper'

RSpec.describe Member, type: :model do
  it "has a valid factory" do
    expect(create(:member)).to be_valid
  end

  describe "validations" do
    describe "#url_format" do
      subject {Member.new(url: "asdawea")}

      pending "returns errors is url is bad"
      #   subject.validate
      #   expect(subject.errors[:url]).to include("Invalid URL format")
      # end
    end
  end

  describe '.get_original_url(unique_key: )' do
    subject {create(:member, url: "http://example.com/1")}
    let(:member_2) {create(:member, url: "http://example.com/2")}

    it "returns the correct, unique original url" do
      allow_any_instance_of(Member).to receive(:generate_url_topics).and_return(true)

      expect(Member.get_original_url(unique_key: subject.unique_key)).to eq(subject.url)
      expect(Member.get_original_url(unique_key: member_2.unique_key)).to eq(member_2.url)

      expect(Member.get_original_url(unique_key: subject.unique_key)).to_not eq(member_2.url)
      expect(Member.get_original_url(unique_key: member_2.unique_key)).to_not eq(subject.url)
    end
  end

  describe "#full_name" do
    subject { create(:member)}
    
    it "returns the full name" do
      expect(subject.full_name).to eq(subject.first_name+" "+subject.last_name)
    end
  end

  describe '#generate topics' do
    subject {create(:member, url: File.join(Rails.root, 'spec', 'fixtures', 'test.xml'))}

    it 'creates member topics' do
      expect {
          subject
      }.to change{Topic.count}.by(3)
    end
  end

end
