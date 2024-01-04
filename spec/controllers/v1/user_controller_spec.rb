require 'rails_helper'

RSpec.describe V1::UserController, type: :controller do
  let(:preexisting_password) { Faker::Crypto.md5 }
  let!(:preexisting_user) { create(:user, password: preexisting_password) }

  describe '#create' do
    before do
      User.create(
        email: 'already_exists@example.com',
        password: 'password',
        password_confirmation: 'password',
        first_name: 'Frank',
        last_name: 'Smith'
      )
    end

    context 'with a valid user' do
      it 'creates a new user' do
        create_params = {
          user: { email: 'dne@test.com', password: '123123123', password_confirmation: '123123123', first_name: 'Frank', last_name: 'Smith' }
        }

        expect { post :create, params: create_params }.to change(User, :count).by(1)
      end
    end

    context 'with an email that already existing with incorrect password' do
      it 'returns correct error message' do
        create_params = {
          user: { email: 'already_exists@example.com', password: 'diffpass', password_confirmation: 'diffpass', first_name: 'Frank', last_name: 'Smith' }
        }
        post :create, params: create_params
        expect(payload['error']).to eq 'This email address has already been registered'
      end
    end

    context 'with invalid parameters' do
      it 'returns the correct error message' do
        create_params = { user: { email: 'different_email@example.com', password: 'password', password_confirmation: 'password' } }

        post :create, params: create_params
        expect(payload['error']).to eq "Validation failed: First name can't be blank, Last name can't be blank"
      end
    end

    context 'with an email that already exists with correct password' do
      let(:create_params) do
        {
          user: {
            email: preexisting_user.email,
            password: preexisting_password,
            password_confirmation: preexisting_password,
            first_name: 'Frank',
            last_name: 'Smith'
          }
        }
      end

      before do
        User.create(email: 'already_exists@example.com', password: 'password', password_confirmation: 'password', first_name: 'Frank', last_name: 'Smith')
      end

      it 'returns existing user with token' do
        post :create, params: create_params
        expect(payload['authToken']).not_to be_nil
      end
    end
  end

  describe '#update' do
    context 'with valid authToken' do
      let(:password) { 'password' }
      let(:user) { create(:user, first_name: 'Jorj') }

      before do
        authenticate(user)
      end

      it 'updates an existing user' do
        put :update, params: { user: { first_name: 'Sam' } }

        user.reload
        expect(user.first_name).to eq('Sam')
      end
    end

    context 'without authToken' do
      it 'throws an error' do
        put :update, params: { user: { first_name: 'Sam' } }
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
