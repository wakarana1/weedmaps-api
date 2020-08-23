require 'rails_helper'

RSpec.describe "Users", type: :request do
  let(:user1)   { create(:user, name: "Joe Weedmaps") }
  let(:user2)   { create(:user) }
  let(:valid_attributes) do
    attributes_for(:user)
  end
  let(:headers) { { "Authorization" => token_generator(user1.id), "Content-Type" => "application/json"} }

  let(:med_rec1) { create(:medical_recommendation, user_id: user1.id) }
  let(:identification) { create(:identification, user_id: user1.id) }

  let(:parsed_body) { JSON.parse(response.body) }

  describe "request index of all users" do
    context "with users" do
      it "can see a list of users" do
        user1
        user2
        get '/api/users', headers: headers

        expect(response).to be_successful
        expect(parsed_body[0]['name']).to eq('Joe Weedmaps')
      end
    end
  end

  describe 'request to show a single user' do

    context 'with a valid user_id' do
      before do
        user1
      end

      it 'can view the user' do
        get "/api/users/#{user1.id}", headers: headers
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
        get "/api/users/#{user1.id}", headers: headers
        expect(response).to be_successful
        expect(parsed_body['name']).to eq("Joe Weedmaps")
      end

      it 'can view users medical rec' do
        get "/api/users/#{user1.id}", headers: headers
        expect(parsed_body).to include('medical_recommendation')
        expect(parsed_body['medical_recommendation']['user_id']).to eq(user1.id)
      end

      it 'can view users identification' do
        get "/api/users/#{user1.id}", headers: headers
        expect(parsed_body).to include('identification')
        expect(parsed_body['medical_recommendation']['user_id']).to eq(user1.id)
      end
    end

    context 'with an invalid user_id' do
      it 'throws an error' do
        get "/api/users/1234567", headers: headers
        expect(response).to_not be_successful
        expect(parsed_body['errors']['id']).to eq(["Incorrect User ID"])
      end
    end
  end

  describe 'requests to create a new user' do
    context 'with valid params' do
      it 'can create a new user' do
        params = {
          name: 'Joe Weedmaps',
          email: Faker::Internet.email(domain: 'weedmaps'),
          dob: Faker::Date.between(from: 50.years.ago, to: 18.years.ago),
          password: '123456789',
          password_confirmation: '123456789'
        }
        post '/api/users', params: params
        expect(response).to be_successful
        expect(parsed_body['message']).to eq('Account created successfully')
      end
    end

    context 'with invalid params' do
      it 'nil name throws error' do
        params = {
          name: nil,
          email: Faker::Internet.email(domain: 'weedmaps'),
          dob: Faker::Date.between(from: 50.years.ago, to: 18.years.ago),
          password: "123456789",
          password_confirmation: "123456789"
        }.to_json
        post '/api/users', params: params
        expect(parsed_body['errors']['name']).to eq(["can't be blank"])
      end

      it 'nil email throws error' do
        params = {
          name: "Joe Weedmaps",
          email: nil,
          dob: Faker::Date.between(from: 50.years.ago, to: 18.years.ago),
          password: "123456789",
          password_confirmation: "123456789"
        }.to_json
        post '/api/users', params: params
        expect(parsed_body['errors']['email']).to eq(["can't be blank", "is invalid"])
      end

      it 'incorrect email throws error' do
        params = {
          name: "Joe Weedmaps",
          email: "email.email.com",
          dob: Faker::Date.between(from: 50.years.ago, to: 18.years.ago),
          password: "123456789",
          password_confirmation: "123456789"
        }.to_json
        post '/api/users', params: params
        expect(parsed_body['errors']['email']).to eq(["can't be blank", "is invalid"])
      end

      it 'nil dob throws error' do
        params = {
          name: "Joe Weedmaps",
          email: Faker::Internet.email(domain: 'weedmaps'),
          dob: nil,
          password: "123456789",
          password_confirmation: "123456789"
        }.to_json
        post '/api/users', params: params
        expect(parsed_body['errors']['dob']).to eq(["can't be blank"])
      end
    end
  end

  describe 'request to update' do
    before { user1 }
    context 'with valid params' do
      it 'is successful' do
        params = {name: "Chris Weedmaps"}.to_json
        patch "/api/users/#{user1.id}", params: params, headers: headers
        expect(response).to be_successful
        expect(parsed_body['name']).to eq("Chris Weedmaps")
      end
    end

    context 'with invalid params' do
      it 'nil name throws error' do
        params = {name: nil}.to_json
        patch "/api/users/#{user1.id}", params: params, headers: headers
        expect(response).to_not be_successful
        expect(parsed_body['errors']['name']).to eq(["can't be blank"])
      end
      it 'nil email throws error' do
        params = {email: nil}.to_json
        patch "/api/users/#{user1.id}", params: params, headers: headers
        expect(response).to_not be_successful
        expect(parsed_body['errors']['email']).to eq(["can't be blank", "is invalid"])
      end
      it 'nil dob throws error' do
        params = {dob: nil}.to_json
        patch "/api/users/#{user1.id}", params: params, headers: headers
        expect(response).to_not be_successful
        expect(parsed_body['errors']['dob']).to eq(["can't be blank"])
      end
    end
  end

  describe 'requests to delete' do
    before { user1 }
    context 'valid user' do
      it 'deletes a user' do
        delete "/api/users/#{user1.id}", headers: headers
        expect(response).to be_successful
        expect(response.status).to eq(200)
        expect(parsed_body['message']).to eq("deleted")
      end
    end
  end

  # # User signup test suite
  # describe 'POST /api/signup' do
  #   context 'when valid request' do
  #     before do
  #        post '/api/signup', params: valid_attributes.to_json
  #     end

  #     it 'creates a new user' do
  #       expect(response).to have_http_status(201)
  #     end

  #     it 'returns success message' do
  #       expect(parsed_body['message']).to match(/Account created successfully/)
  #     end

  #     it 'returns an authentication token' do
  #       expect(parsed_body['auth_token']).not_to be_nil
  #     end
  #   end

  #   context 'when invalid request' do
  #     before { post '/api/signup', params: {} }

  #     it 'does not create a new user' do
  #       expect(response).to have_http_status(422)
  #     end

  #     it 'returns failure message' do
  #       expect(parsed_body['message'])
  #         .to match(/Validation failed: Password can't be blank, Name can't be blank, Email can't be blank, Password digest can't be blank/)
  #     end
  #   end
  # end
end
