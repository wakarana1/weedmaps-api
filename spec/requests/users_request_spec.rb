require 'rails_helper'

RSpec.describe "Users", type: :request do
  let(:user1)   { create(:user, name: "Joe Weedmaps") }
  let(:user2)   { create(:user) }

  let(:med_rec1) { create(:medical_recommendation, user_id: user1.id) }
  let(:identification) { create(:identification, user_id: user1.id) }

  let(:parsed_body) { JSON.parse(response.body) }

  describe "request index of all users" do
    context "with users" do
      it "can see a list of users" do
        user1
        user2
        get '/api/users'
        expect(response).to be_successful
        expect(response.body).to include("Joe Weedmaps")
      end
    end
    context "without any users" do
      it "cannot see a list of users" do
        get '/api/users'
        expect(response).to be_successful
        expect(response.body).to eq '[]'
      end
    end
  end

  describe 'request to show a single user' do

    context 'with a valid user_id' do
      before do
        user1
      end

      it 'can view the user' do
        get "/api/users/#{user1.id}"
        expect(response).to be_successful
        expect(parsed_body['name']).to eq("Joe Weedmaps")
        expect(parsed_body).to_not include('medical_recommendation')
        expect(parsed_body).to_not include('identification')
      end
    end

    context 'with a valid user_id and associations' do
      before do
        user1
        med_rec1
        identification
      end

      it 'can view the user' do
        get "/api/users/#{user1.id}"
        expect(response).to be_successful
        expect(parsed_body['name']).to eq("Joe Weedmaps")
      end

      it 'can view users medical rec' do
        get "/api/users/#{user1.id}"
        expect(parsed_body).to include('medical_recommendation')
        expect(parsed_body['medical_recommendation']['user_id']).to eq(user1.id)
      end

      it 'can view users identification' do
        get "/api/users/#{user1.id}"
        expect(parsed_body).to include('identification')
        expect(parsed_body['medical_recommendation']['user_id']).to eq(user1.id)
      end
    end

    context 'with an invalid user_id' do
      it 'throws an error' do
        get "/api/users/1234567"
        expect(response).to_not be_successful
        expect(parsed_body['errors']['id']).to eq(["Incorrect User ID"])
      end
    end
  end

  describe 'requests to create a new user' do
    context 'with valid params' do
      it 'can create a new user' do
        params = {
          name: "Joe Weedmaps",
          email: Faker::Internet.email(domain: 'weedmaps'),
          dob: Faker::Date.between(from: 50.years.ago, to: 18.years.ago)
        }
        post '/api/users', params: params
        expect(response).to be_successful
        expect(parsed_body['name']).to eq("Joe Weedmaps")
      end
    end

    context 'with invalid params' do
      it 'nil dob throws error' do
        params = {
          name: nil,
          email: Faker::Internet.email(domain: 'weedmaps'),
          dob: Faker::Date.between(from: 50.years.ago, to: 18.years.ago)
        }
        post '/api/users', params: params
        expect(parsed_body['errors']['name']).to eq(["can't be blank"])
      end

      it 'nil email throws error' do
        params = {
          name: "Joe Weedmaps",
          email: nil,
          dob: Faker::Date.between(from: 50.years.ago, to: 18.years.ago)
        }
        post '/api/users', params: params
        expect(parsed_body['errors']['email']).to eq(["can't be blank", "is invalid"])
      end

      it 'incorrect email throws error' do
        params = {
          name: "Joe Weedmaps",
          email: "email.email.com",
          dob: Faker::Date.between(from: 50.years.ago, to: 18.years.ago)
        }
        post '/api/users', params: params
        expect(parsed_body['errors']['email']).to eq(["is invalid"])
      end

      it 'nil dob throws error' do
        params = {
          name: "Joe Weedmaps",
          email: Faker::Internet.email(domain: 'weedmaps'),
          dob: nil
        }
        post '/api/users', params: params
        expect(parsed_body['errors']['dob']).to eq(["can't be blank"])
      end
    end
  end

  describe 'request to update' do
    before { user1 }
    context 'with valid params' do
      it 'is successful' do
        params = {name: "Chris Weedmaps"}
        patch "/api/users/#{user1.id}", params: params
        expect(response).to be_successful
        expect(parsed_body['name']).to eq("Chris Weedmaps")
      end
    end

    context 'with invalid params' do
      it 'nil name throws error' do
        params = {name: nil}
        patch "/api/users/#{user1.id}", params: params
        expect(response).to_not be_successful
        expect(parsed_body['errors']['name']).to eq(["can't be blank"])
      end
      it 'nil email throws error' do
        params = {email: nil}
        patch "/api/users/#{user1.id}", params: params
        expect(response).to_not be_successful
        expect(parsed_body['errors']['email']).to eq(["can't be blank", "is invalid"])
      end
      it 'nil dob throws error' do
        params = {dob: nil}
        patch "/api/users/#{user1.id}", params: params
        expect(response).to_not be_successful
        expect(parsed_body['errors']['dob']).to eq(["can't be blank"])
      end
    end
  end

  describe 'requests to delete' do
    before { user1 }
    context 'valid user' do
      it 'deletes a user' do
        delete "/api/users/#{user1.id}"
        expect(response).to be_successful
        expect(response.status).to eq(200)
        expect(parsed_body['message']).to eq("deleted")
      end
    end
  end
end
