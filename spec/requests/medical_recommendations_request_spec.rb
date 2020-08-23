require 'rails_helper'

RSpec.describe "MedicalRecommendations", type: :request do
  let(:user)   { create(:user, name: "Joe Weedmaps") }
  let(:med_rec) { create(:medical_recommendation, user_id: user.id) }
  let(:user_1)   { create(:user) }
  let(:expired_med_rec) { create(:medical_recommendation, user_id: user_1.id, expiration_date: Date.today - 1) }

  let(:parsed_body) { JSON.parse(response.body) }

  describe "request show medical recommendation for a user" do
    context 'with a user' do
      it 'shows a med rec' do
        user
        med_rec
        get "/api/users/#{user.id}/med_recs/#{med_rec.id}"
        expect(response).to be_successful
        expect(parsed_body['issuer']).to eq(med_rec.issuer)
      end
    end

    context 'with invalid med_rec ID' do
      it 'throws an error' do
        user
        get "/api/users/#{user.id}/med_recs/123456789"
        expect(response).to_not be_successful
        expect(parsed_body['errors']['id']).to eq(["Incorrect Medical Recommendation ID"])
      end
    end

    context 'with an expired med_rec' do
      it 'shows an expired message' do
        user_1
        expired_med_rec
        get "/api/users/#{user_1.id}/med_recs/#{expired_med_rec.id}"
        expect(response).to be_successful
        expect(parsed_body['message']).to eq("Medical Recommendation is expired")
      end
    end
  end

  describe 'request to create medical recommendation' do
    context 'with valid params' do
      it 'will create a medical recommendation' do
        params = {
          number: Faker::Number.number(digits: 9),
          issuer: "Golden Grove Department County Department of Public Health",
          state: Faker::Address.state_abbr,
          expiration_date: Faker::Date.forward(days: 365),
          image_url: Faker::Fillmurray.image
        }
        post "/api/users/#{user.id}/med_recs", params: params
        expect(response).to be_successful
        expect(parsed_body['user_id']).to eq(user.id)
        expect(parsed_body['issuer']).to eq("Golden Grove Department County Department of Public Health")
      end
    end

    context 'with invalid params' do
      params = {
        number: nil,
        issuer: "Golden Grove Department County Department of Public Health",
        state: nil,
        expiration_date: nil,
        image_url: Faker::Fillmurray.image
      }
      it 'nil fields throw error' do
        post "/api/users/#{user.id}/med_recs", params: params
        expect(response).to_not be_successful
        expect(parsed_body['errors']['number']).to eq(["can't be blank"])
        expect(parsed_body['errors']['state']).to eq(["can't be blank"])
        expect(parsed_body['errors']['expiration_date']).to eq(["can't be blank"])
      end
    end

    context 'with expired med rec' do
      it 'shows expired message' do
        params = {
          number: Faker::Number.number(digits: 9),
          issuer: "Golden Grove Department County Department of Public Health",
          state: Faker::Address.state_abbr,
          expiration_date: Date.today - 1,
          image_url: Faker::Fillmurray.image
        }
        post "/api/users/#{user.id}/med_recs", params: params
        expect(response).to be_successful
        expect(parsed_body['message']).to eq("Medical Recommendation is expired")
      end
    end
  end

  describe 'request to update medical recommendation' do
    context 'with valid params' do
      it 'will update a medical recommendation' do
        med_rec
        update_params = {
          state: 'CA',
        }
        patch "/api/users/#{user.id}/med_recs/#{med_rec.id}", params: update_params
        expect(response).to be_successful
        expect(parsed_body['state']).to eq('CA')
      end
    end

    context 'with expired date' do
      it 'will update a medical recommendation' do
        med_rec
        update_params = {
          expiration_date: Date.today - 1
        }
        patch "/api/users/#{user.id}/med_recs/#{med_rec.id}", params: update_params
        expect(response).to be_successful
        expect(parsed_body['message']).to eq("Medical Recommendation is expired")
      end

      it 'shows med rec with future expiration date' do
        expired_med_rec
        update_params = { expiration_date: Date.today + 1 }
        patch "/api/users/#{user_1.id}/med_recs/#{expired_med_rec.id}", params: update_params
        expect(parsed_body['message']).to_not eq("Medical Recommendation is expired")
        expect(parsed_body['id']).to eq(expired_med_rec.id)
        expect(parsed_body['expiration_date']).to eq((Date.today + 1).to_s)
      end
    end
  end

  describe 'request to delete medical recommendation' do
    context 'with a valid med rec' do
      it 'deletes med rec' do
        med_rec
        delete "/api/users/#{user.id}/med_recs/#{med_rec.id}"
        expect(response).to be_successful
        expect(response.status).to eq(200)
        expect(parsed_body['message']).to eq("deleted")
      end
    end
  end
end
