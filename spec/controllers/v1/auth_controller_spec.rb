require 'rails_helper'

RSpec.describe V1::AuthController do
  describe '#auth' do
    context 'without params' do
      it 'returns :access_denied' do
        post :auth
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'with invalid email' do
      it 'returns :access_denied' do
        post :auth, params: { email: 'dne@test.com' }
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'with valid email' do
      let(:correct_password) { 'sesame' }
      let(:user) { create(:user, password: correct_password) }

      context 'without password' do
        it 'returns :access_denied' do
          post :auth, params: { email: user.email }
          expect(response).to have_http_status(:unauthorized)
        end
      end

      context 'with bad password' do
        it 'returns :access_denied' do
          post :auth, params: { email: user.email, password: 'prettyplease' }
          expect(response).to have_http_status(:unauthorized)
        end
      end

      context 'with correct password' do
        it 'returns success' do
          post :auth, params: { email: user.email, password: correct_password }, format: :json
          expect(response).to be_successful
        end

        it 'returns the token' do
          post :auth, params: { email: user.email, password: correct_password }
          expect(payload['authToken']).to be_present
        end

        it 'returns a token that works' do
          post :auth, params: { email: user.email, password: correct_password }
          token = JSON.parse(response.body)['authToken']
          request.headers['Authorization'] = "Bearer #{token}"
          get :check
          expect(response).to be_successful
        end
      end
    end
  end
end
