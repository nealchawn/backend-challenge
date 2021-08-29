class MembersController < ApplicationController
  before_action :set_member, only: [:show]

  def index
    @members = Member.all.order(:last_name)
    respond_to do |format|
      format.json {render json: @members}
    end
  end

  def create
      @member = Member.new(member_params)

      respond_to do |format|
          if @member.save
            format.json {render json: @member.to_json}
          else
            format.json {render json: { errors: @member.errors.full_messages}, status: 422}
          end
      end

      rescue ActionController::ParameterMissing
        render json: { error: "Bad Parameters"}, status: 400
  end

  def show
    respond_to do |format|
      format.json # {render json: @member.to_json}
    end
  end

  def personal_url
    unique_key = params[:unique_key]

    original_url = Member.get_original_url(unique_key: unique_key)
    redirect_to original_url
  end


  private

  def set_member
    @member = Member.find(params[:id] || params[:member_id])
    rescue ActiveRecord::RecordNotFound
      render json: { error: "Member Not Found"}, status: 400
  end

  def member_params
      params.require(:member).permit(:email, :first_name, :last_name, :password, :password_confirmation, :url)
  end
end