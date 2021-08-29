class MembersController < ApplicationController
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


  private

  def member_params
      params.require(:member).permit(:email, :first_name, :last_name, :password, :password_confirmation, :url)
  end
end