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

    it 'returns the correct status code' do
      subject
      expect(response).to have_http_status(:success)
    end

    it 'returns an array' do
      subject
      expect(body).to be_an_instance_of(Array)
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
        expect(data.keys).to match(['name', 'url', 'short_url'])
        expect(data.except('short_url').values).to match([member.full_name, member.url])
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

end