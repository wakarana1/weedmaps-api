require 'rails_helper'

RSpec.describe "Identifications", type: :request do
  let(:user)                    { create(:user, name: "Joe Weedmaps") }
  let(:identification)          { create(:identification, user_id: user.id) }
  let(:user_1)                  { create(:user) }
  let(:expired_identification)  { create(:identification, user_id: user_1.id, expiration_date: Date.today - 1) }
  let(:headers)                 { valid_headers }
  let(:parsed_body)             { JSON.parse(response.body) }

  describe "request show identification for a user" do
    context 'with a user' do
      it 'shows an identification' do
        user
        identification
        get "/api/users/#{user.id}/identifications/#{identification.id}", headers: headers
        expect(response).to be_successful
      end
    end

    context 'with invalid identification ID' do
      it 'throws an error' do
        user
        get "/api/users/#{user.id}/identifications/123456789", headers: headers
        expect(response).to_not be_successful
        expect(parsed_body['errors']['id']).to eq(["Incorrect Identification ID"])
      end
    end

    context 'with an expired identification' do
      it 'shows an expired message' do
        user_1
        expired_identification
        get "/api/users/#{user_1.id}/identifications/#{expired_identification.id}", headers: headers
        expect(response).to be_successful
        expect(parsed_body['message']).to eq("Identification is expired")
      end
    end
  end

  describe 'request to create identification' do
    context 'with valid params' do
      it 'will create a identification' do
        params = {
          number: Faker::Number.number(digits: 9),
          state: Faker::Address.state_abbr,
          expiration_date: Faker::Date.forward(days: 365),
          image_url: Faker::Fillmurray.image
        }.to_json

        post "/api/users/#{user.id}/identifications", params: params, headers: headers
        expect(response).to be_successful
        expect(parsed_body['user_id']).to eq(user.id)
      end
    end

    context 'with invalid params' do
      params = {
        number: nil,
        state: nil,
        expiration_date: nil,
        image_url: Faker::Fillmurray.image
      }.to_json

      it 'nil fields throw error' do
        post "/api/users/#{user.id}/identifications", params: params, headers: headers
        expect(response).to_not be_successful
        expect(parsed_body['errors']['number']).to eq(["can't be blank"])
        expect(parsed_body['errors']['state']).to eq(["can't be blank"])
        expect(parsed_body['errors']['expiration_date']).to eq(["can't be blank"])
      end
    end

    context 'with expired identification' do
      it 'shows expired message' do
        params = {
          number: Faker::Number.number(digits: 9),
          state: Faker::Address.state_abbr,
          expiration_date: Date.today - 1,
          image_url: Faker::Fillmurray.image
        }.to_json

        post "/api/users/#{user.id}/identifications", params: params, headers: headers
        expect(response).to be_successful
        expect(parsed_body['message']).to eq("Identification is expired")
      end
    end
  end

  describe 'request to update identification' do
    context 'with valid params' do
      it 'will update an identification' do
        identification
        update_params = { state: 'CA' }.to_json
        patch "/api/users/#{user.id}/identifications/#{identification.id}", params: update_params, headers: headers
        expect(response).to be_successful
        expect(parsed_body['state']).to eq('CA')
      end
    end

    context 'with expired date' do
      it 'will update an identification' do
        identification
        update_params = { expiration_date: Date.today - 1 }.to_json
        patch "/api/users/#{user.id}/identifications/#{identification.id}", params: update_params, headers: headers
        expect(response).to be_successful
        expect(parsed_body['message']).to eq("Identification is expired")
      end

      it 'shows identification with future expiration date' do
        expired_identification
        update_params = { expiration_date: Date.today + 1 }.to_json
        patch "/api/users/#{user_1.id}/identifications/#{expired_identification.id}", params: update_params, headers: headers
        expect(parsed_body['message']).to_not eq("Identification is expired")
        expect(parsed_body['id']).to eq(expired_identification.id)
        expect(parsed_body['expiration_date']).to eq((Date.today + 1).to_s)
      end
    end
  end

  describe 'request to delete identification' do
    context 'with a valid identification' do
      it 'deletes an identification' do
        identification
        delete "/api/users/#{user.id}/identifications/#{identification.id}", headers: headers
        expect(response).to be_successful
        expect(response.status).to eq(200)
        expect(parsed_body['message']).to eq("deleted")
      end
    end
  end
end
