class Friendship < ApplicationRecord
  belongs_to :member
  belongs_to :friend, class_name: 'Member'

  after_create :create_bi_directional_friendship

  private

  def create_bi_directional_friendship
    unless bi_directional_exists
      Friendship.create(member_id: self.friend_id, friend_id: self.member_id)
    end
  end

  def bi_directional_exists
    Friendship.where(member_id: self.friend.id, friend_id: self.member_id).count > 0
  end
end
