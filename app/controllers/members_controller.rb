class MembersController < ApplicationController
  before_action :set_member, only: [:show, :experts]

  def index
    @members = Member.all.order(:last_name)
    respond_to do |format|
      format.json
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
      format.json
    end
  end

  def personal_url
    unique_key = params[:unique_key]

    original_url = Member.get_original_url(unique_key: unique_key)
    redirect_to original_url
  end

  def experts
    experts = get_all_topic_experts
    experts_data = []
    experts.map do |expert|
      next if expert.id == @member.id
      experts_data << generate_expert_data(member: @member, expert: expert)
    end
    respond_to do |format|
      format.json {render json: experts_data}
    end
  end

  private

  def generate_expert_data(member: ,expert: )
    path = (best_path(paths: friendship_route(member: @member, expert: expert, path: [],paths: [])) || []) << expert.id
    {
      'expert_id' => expert.id,
      'expert_name' => expert.full_name,
      'path' => path,
      'path_formatted' => path.map{|member_id| Member.find(member_id).first_name }.join(" -> ")
    }
  end

  def get_all_topic_experts
    Member.joins(:topics).where("topics.title ilike '%#{params["search"]}%'").group("members.id")
  end

  def best_path(paths: )
    paths.min {|a,b| a.length <=> b.length }
  end

  def member_in_current_path(member: , path: )
    path.include?(member.id)
  end

  def member_friends_with_expert(member: , expert: )
    member.friends?(member_id: expert.id)
  end

  def friendship_route(member: @member, expert: , path: [],paths: [])
    unless member_in_current_path(member: member, path: path)
      path << member.id
      if member_friends_with_expert(member: member, expert: expert)
        paths << path
      else
        member.friends.each do |friend|
          paths = friendship_route(member: friend, expert: expert, path: path, paths: paths)
        end
      end
    end
    return paths
  end

  def set_member
    @member = Member.find(params[:id] || params[:member_id])
    rescue ActiveRecord::RecordNotFound
      render json: { error: "Member Not Found"}, status: 400
  end

  def member_params
      params.require(:member).permit(:email, :first_name, :last_name, :password, :password_confirmation, :url)
  end
end