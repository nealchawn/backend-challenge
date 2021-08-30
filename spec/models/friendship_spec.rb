require 'rails_helper'

RSpec.describe Friendship, type: :model do
  describe 'friends' do
    subject {create(:friendship, member_id: member.id, friend_id: member_2.id)}
    let(:member){create(:member)}
    let(:member_2){create(:member)}

    it 'has friendships being bi directional' do
      subject
      
      expect(member.friends).to include(member_2)
      expect(member_2.friends).to include(member)
    end
  end
end
