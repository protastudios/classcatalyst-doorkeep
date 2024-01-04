require 'rails_helper'

RSpec.describe User, type: :model do
  subject(:valid_user) { create(:user) }

  describe '#generate_password_reset_token' do
    it 'returns a JWT with email set' do
      token = valid_user.generate_password_reset_token
      payload, _header = JWT.decode(token, nil, false)
      expect(payload['email']).to eq(valid_user.email)
    end
  end

  describe '#password_reset_token_valid?' do
    let(:token) { valid_user.generate_password_reset_token }

    context 'without a reset token set on the model' do
      it 'returns false for nil' do
        expect(valid_user).not_to be_password_reset_token_valid(nil)
      end

      it 'returns false for random data' do
        expect(valid_user).not_to be_password_reset_token_valid(SecureRandom.bytes(64))
      end

      it 'returns false with a valid reset token' do
        expect(valid_user).not_to be_password_reset_token_valid(token)
      end
    end

    context 'with a reset token set on the model' do
      before do
        valid_user.password_reset_token = token
        valid_user.save!
      end

      it 'returns false for nil' do
        expect(valid_user).not_to be_password_reset_token_valid(nil)
      end

      it 'returns false for random data' do
        expect(valid_user).not_to be_password_reset_token_valid(SecureRandom.bytes(64))
      end

      it 'returns true with a valid reset token' do
        expect(valid_user).to be_password_reset_token_valid(token)
      end

      it 'returns false with a valid reset token if the email has changed' do
        valid_user.email = 'bill@whitehouse.com'
        valid_user.save!
        expect(valid_user).not_to be_password_reset_token_valid(token)
      end

      it 'returns false with an expired token' do
        Timecop.travel(3.hours.from_now) do
          expect(valid_user).not_to be_password_reset_token_valid(token)
        end
      end
    end
  end

  describe '.reset_password! (class level)' do
    let(:new_password) { Faker::Vehicle.license_plate }

    it 'works' do
      valid_user.send_password_reset
      described_class.reset_password!(valid_user.password_reset_token, new_password)
      valid_user.reload
      expect(valid_user.authenticate(new_password)).to be_truthy
    end
  end

  describe '#send_password_reset' do
    let(:reset_url) do
      encoded_token = ERB::Util.url_encode(valid_user.password_reset_token)
      @token_url = "https://CHANGEME/reset_password/#{encoded_token}"
    end

    it 'sends the email async' do
      valid_user
      expect { valid_user.send_password_reset }.to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(1)
    end

    it 'sends an email to the subject' do
      perform_enqueued_jobs do
        valid_user.send_password_reset
      end
      expect(ActionMailer::Base.deliveries.last.to).to eq([valid_user.email])
    end

    it 'sends a multipart email' do
      perform_enqueued_jobs do
        valid_user.send_password_reset
      end
      expect(ActionMailer::Base.deliveries.last.body).to be_multipart
    end

    it 'sends an email containing a link to reset the subject password in the html body' do
      perform_enqueued_jobs do
        valid_user.send_password_reset
      end
      html_part = ActionMailer::Base.deliveries.last.body.parts.find { |part| part.mime_type == 'text/html' }
      expect(html_part.body).to include(reset_url)
    end

    it 'sends an email containing a link to reset the subject password in the text body' do
      perform_enqueued_jobs do
        valid_user.send_password_reset
      end
      text_part = ActionMailer::Base.deliveries.last.body.parts.find { |part| part.mime_type == 'text/plain' }
      expect(text_part.body).to include(reset_url)
    end

    it 'sets the password_reset_token field' do
      perform_enqueued_jobs do
        valid_user.send_password_reset
      end
      expect(valid_user.password_reset_token).to be_present
    end
  end

  describe '#verify_password_reset_token' do
    before do
      valid_user.send_password_reset
    end

    it 'does not reset token when invalid' do
      valid_user.verify_password_reset_token('not the token')
      expect(valid_user.password_reset_token).to be_present
    end

    it 'resets the token when valid' do
      valid_user.verify_password_reset_token(valid_user.password_reset_token)
      expect(valid_user.password_reset_token).to be_blank
    end

    it 'persists the reset when valid' do
      valid_user.verify_password_reset_token(valid_user.password_reset_token)
      valid_user.reload
      expect(valid_user.password_reset_token).to be_blank
    end
  end
end
