require 'rails_helper'

RSpec.describe Identity, type: :model do
  describe '.find_or_create_from_auth_hash' do
    subject(:id) { described_class.find_or_create_from_auth_hash(auth_hash) }

    let(:provider) { 'linkedin' }
    let(:uid) { 'supercool' }
    let(:hash_name) { 'Jorg the Great' }
    let(:auth_hash) do
      {
        provider: provider,
        uid: uid,
        info: {
          name: hash_name,
          email: 'jorg@test.com'
        },
        extra: {
          raw_auth_hash: 'jasdlkfasdofineroivndz;fvoinase;doigfared'
        }
      }.stringify_keys
    end

    context 'without existing Identity' do
      it 'creates a new identity' do
        expect(id).to be_present
      end

      it 'sets the info approprately' do
        expect(id.info['name']).to eq(hash_name)
      end
    end

    context 'with existing Identity' do
      let!(:existing_id) { create(:identity, provider: provider, uid: uid) }

      it 'loads the existing identity' do
        expect(id).to eq(existing_id)
      end

      it 'updates info' do
        expect(id.info['name']).to eq(hash_name)
      end
    end
  end

  describe '#register!' do
    context 'without a user' do
      let(:id) { create(:identity, user: nil) }

      it 'creates a new user' do
        expect do
          id.register!
        end.to change(User, :count).by(1)
      end

      it 'associates to the new user' do
        id.register!
        expect(id.user).to be_valid
      end

      context 'without an email' do
        let(:id) { create(:identity, user: nil, email: nil) }

        it 'fails' do
          expect do
            id.register!
          end.to raise_error(ActiveRecord::RecordInvalid)
        end
      end
    end

    context 'with a user' do
      let!(:user) { create(:user) }
      let(:id) { create(:identity, user: user) }

      it 'leaves the user alone' do
        id.register!
        expect(id.user).to eq(user)
      end

      it 'does not create a new user' do
        expect do
          id.register!
        end.not_to change(User, :count)
      end
    end
  end

  describe '#link!' do
    context 'when already associated' do
      let(:id) { create(:identity) }

      context 'with different user' do
        let(:user) { create(:user) }

        it 'fails' do
          expect do
            id.link!(user)
          end.to raise_error('authentication mismatch')
        end
      end

      context 'with same user' do
        let(:user) { id.user }

        it 'succeeds' do
          expect do
            id.link!(user)
          end.not_to raise_exception
        end
      end
    end

    context 'without a user set' do
      let(:id) { create(:identity, user: nil) }
      let(:user) { create(:user) }

      it 'associates the user' do
        id.link!(user)
        expect(id.user).to eq(user)
      end
    end
  end
end
