class FriendshipsController < ApplicationController
  before_action :set_member
  
  def create
    @friendship = Friendship.new(friendship_params)
    respond_to do |format|
      if @friendship.save
        format.json {render json: @friendship.to_json}
      else
        format.json {render json: {errors: @friendship.errors.full_messages}, status: 422}
      end
    end

    rescue ActionController::ParameterMissing
      render json: {error: "Bad Parameters"}, status: 400
  end

  private

  def friendship_params
    params.require(:friendship).permit(:member_id, :friend_id)
  end

  def set_member
    @member = Member.find(params[:member_id])
  end
end