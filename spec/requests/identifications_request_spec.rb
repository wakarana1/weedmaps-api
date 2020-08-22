require 'rails_helper'

RSpec.describe "Identifications", type: :request do
  let(:user)   { create(:user, name: "Joe Weedmaps") }
  let(:identification) { create(:identification, user_id: user.id) }
  let(:user_1)   { create(:user) }
  let(:expired_identification) { create(:identification, user_id: user_1.id, expiration_date: Date.today - 1) }

  let(:parsed_body) { JSON.parse(response.body) }

  describe "request show identification for a user" do
    context 'with a user' do
      it 'shows an identification' do
        user
        identification
        get "/api/users/#{user.id}/identifications/#{identification.id}"
        expect(response).to be_successful
      end
    end

    context 'with an expired identification' do
      it 'shows an expired message' do
        user_1
        expired_identification
        get "/api/users/#{user_1.id}/identifications/#{expired_identification.id}"
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
        }
        post "/api/users/#{user.id}/identifications", params: params
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
      }
      it 'nil fields throw error' do
        post "/api/users/#{user.id}/identifications", params: params
        expect(response).to_not be_successful
        expect(parsed_body['errors']['number']).to eq(["can't be blank"])
        expect(parsed_body['errors']['state']).to eq(["can't be blank"])
        expect(parsed_body['errors']['expiration_date']).to eq(["can't be blank"])
      end
    end

    context 'with expiredn identification' do
      it 'shows expired message' do
        params = {
          number: Faker::Number.number(digits: 9),
          state: Faker::Address.state_abbr,
          expiration_date: Date.today - 1,
          image_url: Faker::Fillmurray.image
        }
        post "/api/users/#{user.id}/identifications", params: params
        expect(response).to be_successful
        expect(parsed_body['message']).to eq("Identification is expired")
      end
    end
  end

  describe 'request to update identification' do
    context 'with valid params' do
      it 'will update a identification' do
        identification
        update_params = {
          state: 'CA',
        }
        patch "/api/users/#{user.id}/identifications/#{identification.id}", params: update_params
        expect(response).to be_successful
        expect(parsed_body['state']).to eq('CA')
      end
    end

    context 'with expired date' do
      it 'will update a identification' do
        identification
        update_params = {
          expiration_date: Date.today - 1
        }
        patch "/api/users/#{user.id}/identifications/#{identification.id}", params: update_params
        expect(response).to be_successful
        expect(parsed_body['message']).to eq("Identification is expired")
      end

      it 'showsn identification with future expiration date' do
        expired_identification
        update_params = { expiration_date: Date.today + 1 }
        patch "/api/users/#{user_1.id}/identifications/#{expired_identification.id}", params: update_params
        expect(parsed_body['message']).to_not eq("Identification is expired")
        expect(parsed_body['id']).to eq(expired_identification.id)
        expect(parsed_body['expiration_date']).to eq((Date.today + 1).to_s)
      end
    end
  end

  describe 'request to delete identification' do
    context 'with a validn identification' do
      it 'deletesn identification' do
        identification
        delete "/api/users/#{user.id}/identifications/#{identification.id}"
        expect(response).to be_successful
        expect(response.status).to eq(200)
        expect(parsed_body['message']).to eq("deleted")
      end
    end
  end
end
