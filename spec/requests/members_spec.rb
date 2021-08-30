require 'rails_helper'

describe 'Members', type: :request do
  let(:body) { JSON.parse(response.body) }
  let(:headers) { { "Accept" => "application/json", 'Content-Type' => 'application/json' } }

  describe 'creating a member' do
    subject { post '/members', params: params.to_json, headers: headers }

    context 'with valid params' do
      let(:params) do
        {
          member: {
            first_name: 'Sandi',
            last_name: 'Metz',
            url: 'http://www.example.com',
            email: 'chawnneal@gmail.com',
            password: 'password',
            password_confirmation: 'password',
          }
        }
      end

      it 'returns the correct status code' do
        subject
        expect(response).to have_http_status(:success)
      end
    end

    context 'with missing params' do
      let(:params) { {} }

      it 'returns the correct status code' do
        subject
        expect(response).not_to have_http_status(:success)
      end
    end
  end

  describe 'viewing all members' do
    subject { get '/members', headers: headers }
    let(:member_1){create(:member)}
    let(:member_2){create(:member)}
    let(:member_3){create(:member)}

    it 'returns the correct status code' do
      subject
      expect(response).to have_http_status(:success)
    end

    it 'returns an array' do
      subject
      expect(body).to be_an_instance_of(Array)
    end

    it "returns the correct data" do
      create_friendships
      subject

      data = JSON.parse(response.body)
      expect(data.first.keys).to match(['name', 'short_url', 'total_friends'])
      expect(data.map{|member| member.except('short_url')}).to match(JSON.parse(expected_data))
    end

    def create_friendships
      create(:friendship, member_id: member_1.id, friend_id: member_2.id)
      create(:friendship, member_id: member_3.id, friend_id: member_2.id)
    end

    def expected_data
      [
        {name: member_1.full_name ,total_friends: 1},
        {name: member_2.full_name ,total_friends: 2},
        {name: member_3.full_name ,total_friends: 1}
    ].to_json
    end
  end

  describe 'viewing a member' do
    context 'when member exists' do
      subject { get "/members/#{member.id}", headers: headers }
      let(:member) {create(:member)}

      it 'returns the correct status code' do
        subject
        expect(response).to have_http_status(:success)
      end

      it "returns the correct data" do
        subject

        data = JSON.parse(response.body)
        expect(data.keys).to match(['name', 'url', 'short_url', 'topics', 'friends_urls', 'friends'])
        
        expect(data.except('short_url', 'friends_urls').values).to match([member.full_name, member.url, member.topics.map(&:title), member.friends])
      end
    end

    context 'when member not found' do
      subject { get '/members/0', headers: headers }

      it 'returns the correct status code' do
        subject
        expect(response).not_to have_http_status(:success)
      end
    end
  end

  describe 'viewing a short link' do
    subject {get "#{member.short_url}", headers: headers}
    let(:member) {create(:member)}

    it 'redirects to the original url' do
      generate_dummy_members
      subject
      expect(response).to redirect_to(member.url)
    end

    def generate_dummy_members
      create(:member)
      create(:member)
    end
  end
  
  describe 'get experts path' do
    let(:member) {create(:member)}
    let!(:m2) {create(:member)}
    let!(:m3) {create(:member)}
    subject { get "/members/#{member.id}/experts", params: params, headers: headers }

    let(:params) do
      {
        search: "header"
      }
    end

    it 'returns the path for each expert' do
      setup_friendships
      subject
      expect(JSON.parse(response.body)).to eq(JSON.parse(paths_data))
    end

    it 'returns path to self if no relationship exists, but there is an expert' do
      subject
      expect(JSON.parse(response.body)).to eq(JSON.parse([
        {
          expert_id: m2.id,
          expert_name: m2.full_name,
          path: [m2.id],
          path_formatted: m2.first_name
        },
        {
          expert_id: m3.id,
          expert_name: m3.full_name,
          path: [m3.id],
          path_formatted: m3.first_name
        }
      ].to_json))
    end

    it 'returns the best path for each expert' do
      setup_friendships_best
      subject
      expect(JSON.parse(response.body)).to eq(JSON.parse([
        {
          expert_id: m2.id,
          expert_name: m2.full_name,
          path: [ member.id, m2.id],
          path_formatted: [ member.first_name, m2.first_name].join(" -> ")
        },
        {
          expert_id: m3.id,
          expert_name: m3.full_name,
          path: [ member.id, m3.id],
          path_formatted: [ member.first_name, m3.first_name].join(" -> ")
        }
      ].to_json))
    end

    it 'returns empty array if there are no experts' do
      get "/members/#{member.id}/experts", params: {search: "bad search"}, headers: headers
      expect(JSON.parse(response.body)).to eq([])
    end

    

    def paths_data
      [
        {
          expert_id: m2.id,
          expert_name: m2.full_name,
          path: [ member.id, m2.id],
          path_formatted: [ member.first_name, m2.first_name].join(" -> ")
        },
        {
          expert_id: m3.id,
          expert_name: m3.full_name,
          path: [ member.id, m2.id, m3.id],
          path_formatted: [ member.first_name, m2.first_name, m3.first_name].join(" -> ")
        }
      ].to_json
    end

    def setup_friendships
      create(:friendship, member: m2, friend: member)
      create(:friendship, member: m2, friend: m3)
    end

    def setup_friendships_best
      create(:friendship, member: m2, friend: member)
      create(:friendship, member: m2, friend: m3)
      create(:friendship, member: member, friend: m3)
    end
  end

end